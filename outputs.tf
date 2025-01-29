output "lb_dns_name" {
  value = module.lb.lb_dns_name
}

output "asg_private_ips" {
  value = module.app_asg.private_ips
}

output "bastion_public_ip" {
  value = module.ec2_bastion_host.public_ip
}