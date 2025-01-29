output "private_ips" {
  value = data.aws_instances.asg_instance.private_ips
}