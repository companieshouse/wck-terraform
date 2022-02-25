output "wck_frontend_address_internal" {
  value = aws_route53_record.wck_alb_internal.fqdn
}
