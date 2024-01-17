# ------------------------------------------------------------------------------
# External ALB Security Group
# ------------------------------------------------------------------------------
module "wck_external_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-alb-001"
  description = "Security group for the ${var.application} web servers"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = concat(
    var.fe_public_access_cidrs,
    formatlist("%s/32", [for eni in data.aws_network_interface.nlb_fe_external : eni.private_ip])
  )

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

#--------------------------------------------
# External ALB Resource
#--------------------------------------------
module "wck_external_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.16.0"

  name                       = "alb-${var.application}-external-001"
  vpc_id                     = data.aws_vpc.vpc.id
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true

  security_groups = [module.wck_external_alb_security_group.this_security_group_id]
  subnets         = data.aws_subnet_ids.public.ids

  access_logs = {
    bucket  = local.elb_access_logs_bucket_name
    prefix  = local.elb_access_logs_prefix
    enabled = true
  }

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type        = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.acm_cert.arn
      target_group_index = 0
      action_type        = "fixed-response"
      fixed_response     = {
        content_type     = "text/html"
        message_body     = file("${path.module}/files/fe_alb_external_message_body.html")
        status_code      = "200"
      }
    }
  ]

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-FE-Support"
    )
  )
}
