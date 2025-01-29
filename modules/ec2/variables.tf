variable "environment" {
  type    = string
  default = "dev"
}

variable "ami_name" {
  type        = string
  description = "AMI name"
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"
}

variable "ami_owner" {
  type        = string
  description = "ami owner"
  default     = "099720109477"
}

variable "architecture" {
  type        = string
  description = "architecture for the ec2 instance"
  default     = "x86_64"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
  description = "The VPC Subnet ID to launch in"
}

variable "key_name" {
  type        = string
  description = "The key name to use for the instance"
}

variable "instance_name" {
  type        = string
  description = "EC2 instance name"
}

variable "security_group_ids" {
  type        = list(string)
  description = "list of security groups"
}