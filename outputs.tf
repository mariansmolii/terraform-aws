output "lb_dns_name" {
  value = module.lb.lb_dns_name
}

output "asg_private_ips" {
  value = module.app-asg.private_ips
}