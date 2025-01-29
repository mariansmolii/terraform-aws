module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr_block      = var.vpc_cidr_block
  nat_count           = 2
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
}

module "lb_sg" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "lb-sg"
  sg_description = "Security group for load balancer"
  ingress_rules = [for port in var.lb_sg_ports : {
    port      = tonumber(port)
    cidr_ipv4 = "0.0.0.0/0"
  }]
}

module "app_sg" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "app-sg"
  sg_description = "Security group for application"
  ingress_rules = [{
    port         = 80
    source_sg_id = module.lb_sg.sg_id
  }]
}

module "lb" {
  source            = "./modules/lb"
  vpc_id            = module.vpc.vpc_id
  lb_name           = "app-lb"
  lb_sg_id          = module.lb_sg.sg_id
  public_subnet_ids = module.vpc.public_subnet_ids
  depends_on_igw    = module.vpc.igw_id
}

module "app-asg" {
  source               = "./modules/autoscaling"
  launch_template_name = "app-template"
  asg_name             = "app-asg"
  security_group_id    = module.app_sg.sg_id
  subnet_ids           = module.vpc.private_subnet_ids
  lb_tg_arn            = module.lb.lb_tg_arn
  asg_settings = {
    min     = 2
    desired = 2
    max     = 6
  }
}