resource "aws_route53_record" "wck_frontend_internal" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = var.application
  type    = "A"

  alias {
    name                   = module.nlb_fe_internal.this_lb_dns_name
    zone_id                = module.nlb_fe_internal.this_lb_zone_id
    evaluate_target_health = true
  }
}
