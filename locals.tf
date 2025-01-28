locals {
  app_sg_ports = [{
    port        = "80"
    source_cidr = aws_security_group.lb_sg.id
  }]
}