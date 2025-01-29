resource "aws_lb" "lb" {
  name               = var.lb_name
  load_balancer_type = var.lb_type
  internal           = var.lb_internal
  subnets            = var.public_subnet_ids
  security_groups    = [var.lb_sg_id]
  depends_on         = [var.depends_on_igw]

  tags = {
    Name = "${var.environment}-${var.lb_name}"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.lb_name}-tg"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}