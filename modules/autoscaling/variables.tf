variable "environment" {
  type    = string
  default = "dev"
}

variable "launch_template_name" {
  type        = string
  description = "Name for launch template"
}

variable "image_id" {
  type        = string
  description = "EC2 image ID"
  default     = "ami-0a628e1e89aaedf80"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "user_data" {
  type        = string
  description = "Path to user data script"
  default     = "userdata.sh"
}

variable "security_group_id" {
  type        = string
  description = "List of security groups"
}

variable "asg_name" {
  type        = string
  description = "Name of ASG"
}

variable "lb_tg_arn" {
  type        = string
  description = "ARN of LB"
}

variable "asg_settings" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Autoscaling configuration"
}

variable "health_check_grace_period" {
  type        = number
  default     = 300
  description = "Time in seconds after instance comes into service before checking health"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Autoscaling groups"
}

variable "scale_policy_cooldown" {
  type    = number
  default = 300
}

variable "alarm_settings" {
  type = object({
    scale_up_threshold   = number
    scale_down_threshold = number
    evaluation_periods   = number
    period               = number
  })
  default = {
    scale_up_threshold   = 80
    scale_down_threshold = 30
    evaluation_periods   = 5
    period               = 30
  }
}