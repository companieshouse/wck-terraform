# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs = values(data.vault_generic_secret.internal_cidrs.data)
  test_cidrs  = var.test_access_enable ? jsondecode(data.vault_generic_secret.test_cidrs.data["cidrs"]) : []

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }

# ------------------------------------------------------------------------------
# WCK Common
# ------------------------------------------------------------------------------
  wck_ec2_data = data.vault_generic_secret.wck_ec2_data.data
  s3_releases  = data.vault_generic_secret.s3_releases.data

  kms_keys_data          = data.vault_generic_secret.kms_keys.data
  security_kms_keys_data = data.vault_generic_secret.security_kms_keys.data
  account_ssm_key_arn    = local.kms_keys_data["ssm"]
  logs_kms_key_id        = local.kms_keys_data["logs"]
  sns_kms_key_id         = local.kms_keys_data["sns"]
  ssm_kms_key_id         = local.security_kms_keys_data["session-manager-kms-key-arn"]

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data["session-manager-bucket-name"]

  elb_access_logs_bucket_name = local.security_s3_data["elb-access-logs-bucket-name"]
  elb_access_logs_prefix      = "elb-access-logs"

# ------------------------------------------------------------------------------
# WCK Frontend
# ------------------------------------------------------------------------------
  wck_fe_data = data.vault_generic_secret.wck_fe_data.data_json

  fe_cw_logs = { for log, map in var.fe_cw_logs : log => merge(map, { "log_group_name" = "${var.application}-fe-${log}" }) }
  fe_log_groups = compact([for log, map in local.fe_cw_logs : lookup(map, "log_group_name", "")])

  fe_alb_app_access = length(var.fe_access_cidrs) != 0 ? [
    {
      rule        = "http-80-tcp"
      description = "Application Access"
      cidr_blocks = join(",", var.fe_access_cidrs)
    },
    {
      rule        = "https-443-tcp"
      description = "Application Access"
      cidr_blocks = join(",", var.fe_access_cidrs)
    }
  ] : []

  # Generate listener configuration for FTP passive ports
  wck_fe_ftp_int_passive_listeners = [
    for num in range(var.fe_ftp_int_passive_ports_start, var.fe_ftp_int_passive_ports_end + 1) : {
      port               = format("%d", num)
      protocol           = "TCP"
    }
  ]
  wck_fe_ftp_ext_passive_listeners = [
    for num in range(var.fe_ftp_ext_passive_ports_start, var.fe_ftp_ext_passive_ports_end + 1) : {
      port               = format("%d", num)
      protocol           = "TCP"
    }
  ]

  # Generate target group configuration for FTP passive ports
  # Internal NLB TGs
  wck_fe_internal_ftp_passive_tgs = [
    for num in range(var.fe_ftp_int_passive_ports_start, var.fe_ftp_int_passive_ports_end + 1) : {
      name                 = "tg-${var.application}-fe-int-ftp-${num}"
      backend_protocol     = "TCP"
      backend_port         = num
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        port                = 21
        healthy_threshold   = 3
        unhealthy_threshold = 3
        protocol            = "TCP"
      }
      tags = {
        InstanceTargetGroupTag = var.application
      }
    }
  ]

  # External NLB TGs
  wck_fe_external_ftp_passive_tgs = [
    for num in range(var.fe_ftp_ext_passive_ports_start, var.fe_ftp_ext_passive_ports_end + 1) : {
      name                 = "tg-${var.application}-fe-ext-ftp-${num}"
      backend_protocol     = "TCP"
      backend_port         = num
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        port                = 2121
        healthy_threshold   = 3
        unhealthy_threshold = 3
        protocol            = "TCP"
      }
      tags = {
        InstanceTargetGroupTag = var.application
      }
    }
  ]

  wck_fe_ansible_inputs = {
    s3_bucket_releases         = local.s3_releases["release_bucket_name"]
    s3_bucket_configs          = local.s3_releases["config_bucket_name"]
    heritage_environment       = var.environment
    version                    = var.fe_app_release_version
    default_nfs_server_address = var.nfs_server
    mounts_parent_dir          = var.nfs_mount_destination_parent_dir
    mounts                     = var.nfs_mounts
    region                     = var.aws_region
    cw_log_files               = local.fe_cw_logs
    cw_agent_user              = "root"
  }

# ------------------------------------------------------------------------------
# WCK BEP
# ------------------------------------------------------------------------------
  wck_bep_data = data.vault_generic_secret.wck_bep_data.data_json

  bep_cw_logs = { for log, map in var.bep_cw_logs : log => merge(map, { "log_group_name" = "${var.application}-bep-${log}" }) }
  bep_log_groups = compact([for log, map in local.bep_cw_logs : lookup(map, "log_group_name", "")])

  wck_bep_ansible_inputs = {
    s3_bucket_releases         = local.s3_releases["release_bucket_name"]
    s3_bucket_configs          = local.s3_releases["config_bucket_name"]
    heritage_environment       = var.environment
    version                    = var.bep_app_release_version
    default_nfs_server_address = var.nfs_server
    mounts_parent_dir          = var.nfs_mount_destination_parent_dir
    mounts                     = var.nfs_mounts
    region                     = var.aws_region
    cw_log_files               = local.bep_cw_logs
    cw_agent_user              = "root"
  }

  parameter_store_path_prefix = "/${var.application}/${var.environment}"
  
  parameter_store_secrets = {
    frontend_inputs         = local.wck_fe_data
    frontend_ansible_inputs = jsonencode(local.wck_fe_ansible_inputs)
    backend_inputs          = local.wck_bep_data
    backend_ansible_inputs  = jsonencode(local.wck_bep_ansible_inputs)
    backend_cron_entries    = data.template_file.wck_cron_file.rendered
  }
}
