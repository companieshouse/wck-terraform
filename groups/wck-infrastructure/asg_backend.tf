# ------------------------------------------------------------------------------
# BEP Security Group and rules
# ------------------------------------------------------------------------------
module "wck_bep_asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-bep-asg-001"
  description = "Security group for the ${var.application} backend asg"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_with_cidr_blocks = []

  egress_rules = ["all-all"]

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

resource "aws_cloudwatch_log_group" "wck_bep" {
  for_each = local.bep_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.bep_default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", local.logs_kms_key_id)

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

# ASG Scheduled Shutdown
resource "aws_autoscaling_schedule" "bep-schedule-stop" {
  count = var.bep_asg_schedule_stop ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-shutdown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "00 20 * * 1-5" #Mon-Fri at 8pm
  autoscaling_group_name = module.bep_asg.this_autoscaling_group_name
}

# ASG Scheduled Startup
resource "aws_autoscaling_schedule" "bep-schedule-start" {
  count = var.bep_asg_schedule_start ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-startup"
  min_size               = var.bep_asg_min_size
  max_size               = var.bep_asg_max_size
  desired_capacity       = var.bep_asg_desired_capacity
  recurrence             = "00 06 * * 1-5" #Mon-Fri at 6am
  autoscaling_group_name = module.bep_asg.this_autoscaling_group_name
}

# ASG Module
module "bep_asg" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.36"

  name = "${var.application}-bep"
  # Launch configuration
  lc_name       = "${var.application}-bep-launchconfig"
  image_id      = data.aws_ami.wck_bep_ami.id
  instance_type = var.bep_instance_size
  security_groups = [
    module.wck_bep_asg_security_group.this_security_group_id,
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
  asg_name                       = "${var.application}-bep-asg"
  vpc_zone_identifier            = data.aws_subnet_ids.application.ids
  health_check_type              = "ELB"
  min_size                       = var.bep_asg_min_size
  max_size                       = var.bep_asg_max_size
  desired_capacity               = var.bep_asg_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  refresh_triggers               = ["launch_configuration"]
  key_name                       = aws_key_pair.wck_keypair.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  iam_instance_profile           = module.wck_bep_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.bep_userdata_config.rendered

  tags_as_map = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

#--------------------------------------------
# Backend ASG CloudWatch Alarms
#--------------------------------------------
module "bep_asg_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/asg-cloudwatch-alarms?ref=tags/1.0.108"

  autoscaling_group_name = module.bep_asg.this_autoscaling_group_name
  prefix                 = "${var.application}-bep-asg-alarms"

  in_service_evaluation_periods      = "3"
  in_service_statistic_period        = "120"
  expected_instances_in_service      = var.bep_asg_desired_capacity
  in_pending_evaluation_periods      = "3"
  in_pending_statistic_period        = "120"
  in_standby_evaluation_periods      = "3"
  in_standby_statistic_period        = "120"
  in_terminating_evaluation_periods  = "3"
  in_terminating_statistic_period    = "120"
  total_instances_evaluation_periods = "3"
  total_instances_statistic_period   = "120"
  total_instances_in_service         = var.bep_asg_desired_capacity

  actions_alarm = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []
  actions_ok    = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []


  depends_on = [
    module.cloudwatch_sns_notifications,
    module.bep_asg
  ]
}
