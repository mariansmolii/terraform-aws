variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Key"
  sensitive   = true
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "lb_sg_ports" {
  type        = list(string)
  description = "Ports to allow LB traffic"
  default     = ["80", "443"]
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

variable "asg_min" {
  type        = number
  description = "Min numbers of servers in ASG"
  default     = 2
}

variable "asg_max" {
  type        = number
  description = "Max numbers of servers in ASG"
  default     = 6
}

variable "asg_desired" {
  type        = number
  description = "Desired numbers of servers in ASG"
  default     = 2
}