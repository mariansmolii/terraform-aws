resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rtb"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_eip" "nat_eip" {
  count      = length(var.availability_zones)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway" {
  count             = length(var.availability_zones)
  allocation_id     = aws_eip.nat_eip[count.index].id
  subnet_id         = aws_subnet.public[count.index].id
  connectivity_type = "public"
  depends_on        = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "private_rtb" {
  count  = length(aws_nat_gateway.nat_gateway)
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  depends_on = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "${var.environment}-private-rtb-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Enable web access to load balancer"
  vpc_id      = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.environment}-lb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress_rules" {
  security_group_id = aws_security_group.lb_sg.id
  for_each          = toset(var.lb_sg_ports)
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "lb_sg_egress_rule" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.lb_sg.id]
  depends_on         = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-lb"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for application"
  vpc_id      = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.environment}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_sg_ingress_rules" {
  for_each = { for idx, sg_rule in local.app_sg_ports : idx => sg_rule }

  security_group_id            = aws_security_group.app_sg.id
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value.source_cidr
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress_rule" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_launch_template" "app_template" {
  name          = "app-template"
  image_id      = var.image_id
  instance_type = var.instance_type

  user_data = filebase64("userdata.sh")

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "${var.environment}-app-template"
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-asg"
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  min_size                  = var.asg_min
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = tolist(aws_subnet.private[*].id)
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  termination_policies      = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = aws_launch_template.app_template.latest_version
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "app-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "app-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "scale-up"
  alarm_description   = "Monitoring CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = "5"
  period              = "30"
  threshold           = "80"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "scale-down"
  alarm_description   = "Monitoring CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  evaluation_periods  = "5"
  threshold           = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}