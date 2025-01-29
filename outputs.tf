output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "asg_private_ips" {
  value = data.aws_instances.asg_instances.private_ips
}