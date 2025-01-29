module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr_block      = var.vpc_cidr_block
  nat_count           = 2
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
}

module "bastion_sg" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "bastion-sg"
  sg_description = "Security group for bastion host"
  ingress_rules = [{
    port      = 22
    cidr_ipv4 = var.my_ip
  }]
}

module "bastion_key_pair" {
  source   = "./modules/ssh_key"
  key_name = var.bastion_key_name
  filename = var.bastion_filename
}

module "ec2_bastion_host" {
  source             = "./modules/ec2"
  instance_name      = "bastion-host"
  security_group_ids = [module.bastion_sg.sg_id]
  subnet_id          = module.vpc.public_subnet_ids[0]
  key_name           = module.bastion_key_pair.key_name
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
    }, {
    port         = 22
    source_sg_id = module.bastion_sg.sg_id
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

module "app_key_pair" {
  source   = "./modules/ssh_key"
  key_name = var.app_key_name
  filename = var.app_filename
}

module "app_asg" {
  source               = "./modules/autoscaling"
  launch_template_name = "app-template"
  asg_name             = "app-asg"
  key_name             = module.app_key_pair.key_name
  security_group_id    = module.app_sg.sg_id
  subnet_ids           = module.vpc.private_subnet_ids
  lb_tg_arn            = module.lb.lb_tg_arn
  asg_settings = {
    min     = 2
    desired = 2
    max     = 6
  }
}