resource "aws_launch_template" "this" {
  name          = var.launch_template_name
  image_id      = var.image_id
  instance_type = var.instance_type

  user_data = filebase64(var.user_data)
  key_name  = var.key_name

  network_interfaces {
    security_groups = [var.security_group_id]
  }

  tags = {
    Name = "${var.environment}-${var.launch_template_name}"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  desired_capacity          = var.asg_settings.desired
  max_size                  = var.asg_settings.max
  min_size                  = var.asg_settings.min
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [var.lb_tg_arn]
  termination_policies      = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.environment}-${var.asg_name}"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.asg_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.asg_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "${var.asg_name}-scale-up"
  alarm_description   = "Monitoring CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  evaluation_periods  = var.alarm_settings.evaluation_periods
  period              = var.alarm_settings.period
  threshold           = var.alarm_settings.scale_up_threshold
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "${var.asg_name}-scale-down"
  alarm_description   = "Monitoring CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_settings.period
  evaluation_periods  = var.alarm_settings.evaluation_periods
  threshold           = var.alarm_settings.scale_down_threshold
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

data "aws_instances" "asg_instance" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-${var.asg_name}"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.asg]
}