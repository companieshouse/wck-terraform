locals {
  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data

  elb_access_logs_bucket_name = local.security_s3_data["elb-access-logs-bucket-name"]
  elb_access_logs_prefix      = "elb-access-logs"
}
