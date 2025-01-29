output "lb_arn" {
  value = aws_lb.lb.arn
}

output "lb_tg_arn" {
  value = aws_lb_target_group.lb_tg.arn
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}