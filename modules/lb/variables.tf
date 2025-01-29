variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "lb_name" {
  type        = string
  description = "Name of the load balancer"
}

variable "lb_type" {
  type        = string
  description = "Type of the load balancer"
  default     = "application"
}

variable "lb_internal" {
  type    = bool
  default = false
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet ids for load balancer"
}

variable "lb_sg_id" {
  type        = string
  description = "Security group id for lb"
}

variable "depends_on_igw" {
  type        = string
  description = "internet gateway id"
}

variable "tg_port" {
  type        = number
  description = "Target port number"
  default     = 80
}

variable "tg_protocol" {
  type        = string
  description = "Protocol for target group"
  default     = "HTTP"
}

variable "listener_port" {
  type        = number
  description = "Port for listener"
  default     = 80
}

variable "listener_protocol" {
  type        = string
  description = "Protocol for listener"
  default     = "HTTP"
}