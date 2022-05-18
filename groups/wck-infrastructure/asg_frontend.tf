# ------------------------------------------------------------------------------
# Frontend Security Group and rules
# ------------------------------------------------------------------------------
module "wck_fe_asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-fe-asg-001"
  description = "Security group for the ${var.application} frontend asg"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      description = "Allow FTP connections from internal networks"
      cidr_blocks = join(",", local.admin_cidrs)
    },
    {
      from_port   = var.fe_ftp_int_passive_ports_start
      to_port     = var.fe_ftp_int_passive_ports_end
      protocol    = "tcp"
      description = "Allow FTP passive connections from internal networks"
      cidr_blocks = join(",", local.admin_cidrs)
    },
    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      description = "Allow FTP connections from internal NLB"
      cidr_blocks = join(",", formatlist("%s/32", [for eni in data.aws_network_interface.nlb_fe_internal : eni.private_ip]))
    },
    {
      from_port   = var.fe_ftp_int_passive_ports_start
      to_port     = var.fe_ftp_int_passive_ports_end
      protocol    = "tcp"
      description = "Allow FTP passive connections from internal NLB"
      cidr_blocks = join(",", formatlist("%s/32", [for eni in data.aws_network_interface.nlb_fe_internal : eni.private_ip]))
    },
    {
      from_port   = 2121
      to_port     = 2121
      protocol    = "tcp"
      description = "Allow FTP connections from external NLB"
      cidr_blocks = join(",", formatlist("%s/32", [for eni in data.aws_network_interface.nlb_fe_external : eni.private_ip]))
    },
    {
      from_port   = var.fe_ftp_ext_passive_ports_start
      to_port     = var.fe_ftp_ext_passive_ports_end
      protocol    = "tcp"
      description = "Allow FTP passive connections from external NLB"
      cidr_blocks = join(",", formatlist("%s/32", [for eni in data.aws_network_interface.nlb_fe_external : eni.private_ip]))
    },
    {
      from_port   = 2121
      to_port     = 2121
      protocol    = "tcp"
      description = "Allow FTP connections from external"
      cidr_blocks = join(",", var.fe_public_access_cidrs)
    },
    {
      from_port   = var.fe_ftp_ext_passive_ports_start
      to_port     = var.fe_ftp_ext_passive_ports_end
      protocol    = "tcp"
      description = "Allow FTP passive connections from external"
      cidr_blocks = join(",", var.fe_public_access_cidrs)
    },
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.wck_internal_alb_security_group.this_security_group_id
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.wck_external_alb_security_group.this_security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_rules = ["all-all"]

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-FE-Support"
    )
  )
}

resource "aws_cloudwatch_log_group" "wck_fe" {
  for_each = local.fe_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.fe_default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", local.logs_kms_key_id)

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-FE-Support"
    )
  )
}

# ASG Scheduled Shutdown for non-production
resource "aws_autoscaling_schedule" "fe-schedule-stop" {
  count = var.fe_asg_schedule_stop ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-fe-scheduled-shutdown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "00 20 * * 1-5" #Mon-Fri at 8pm
  autoscaling_group_name = module.fe_asg.this_autoscaling_group_name
}

# ASG Scheduled Startup for non-production
resource "aws_autoscaling_schedule" "fe-schedule-start" {
  count = var.fe_asg_schedule_start ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-fe-scheduled-startup"
  min_size               = var.fe_asg_min_size
  max_size               = var.fe_asg_max_size
  desired_capacity       = var.fe_asg_desired_capacity
  recurrence             = "00 06 * * 1-5" #Mon-Fri at 6am
  autoscaling_group_name = module.fe_asg.this_autoscaling_group_name
}

# ASG Module
module "fe_asg" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.36"

  name = "${var.application}-webserver"
  # Launch configuration
  lc_name       = "${var.application}-fe-launchconfig"
  image_id      = data.aws_ami.wck_fe_ami.id
  instance_type = var.fe_instance_size
  security_groups = [
    module.wck_fe_asg_security_group.this_security_group_id,
    data.aws_security_group.nagios_shared.id
  ]
  root_block_device = [
    {
      volume_size = "40"
      volume_type = "gp2"
      encrypted   = true
      iops        = 0
    },
  ]
  # Auto scaling group
  asg_name                       = "${var.application}-fe-asg"
  vpc_zone_identifier            = data.aws_subnet_ids.web.ids
  health_check_type              = "ELB"
  min_size                       = var.fe_asg_min_size
  max_size                       = var.fe_asg_max_size
  desired_capacity               = var.fe_asg_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  refresh_triggers               = ["launch_configuration"]
  key_name                       = aws_key_pair.wck_keypair.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  target_group_arns              = concat(
    module.wck_external_alb.target_group_arns,
    module.wck_internal_alb.target_group_arns,
    flatten(
      [
        for num in range(2, length(module.nlb_fe_internal.target_group_arns)) : [
          [module.nlb_fe_internal.target_group_arns[num], module.nlb_fe_external.target_group_arns[num]]
        ]
      ]
    )
  )

  iam_instance_profile           = module.wck_fe_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.fe_userdata_config.rendered

  tags_as_map = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-FE-Support"
    )
  )

  depends_on = [
    module.wck_external_alb,
    module.wck_internal_alb
  ]
}

#--------------------------------------------
# Frontend ASG CloudWatch Alarms
#--------------------------------------------
module "fe_asg_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/asg-cloudwatch-alarms?ref=tags/1.0.108"

  autoscaling_group_name = module.fe_asg.this_autoscaling_group_name
  prefix                 = "${var.application}-fe-asg-alarms"

  in_service_evaluation_periods      = "3"
  in_service_statistic_period        = "120"
  expected_instances_in_service      = var.fe_asg_desired_capacity
  in_pending_evaluation_periods      = "3"
  in_pending_statistic_period        = "120"
  in_standby_evaluation_periods      = "3"
  in_standby_statistic_period        = "120"
  in_terminating_evaluation_periods  = "3"
  in_terminating_statistic_period    = "120"
  total_instances_evaluation_periods = "3"
  total_instances_statistic_period   = "120"
  total_instances_in_service         = var.fe_asg_desired_capacity

  actions_alarm = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []
  actions_ok    = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []


  depends_on = [
    module.cloudwatch_sns_notifications,
    module.fe_asg
  ]
}
