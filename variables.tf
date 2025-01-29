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

variable "my_ip" {
  type        = string
  description = "My IP address"
}

variable "bastion_key_name" {
  type        = string
  description = "Bastion key name"
  default     = "bastion-key"
}

variable "bastion_filename" {
  type        = string
  description = "Path where bastion files will be placed"
}

variable "app_key_name" {
  type        = string
  description = "App key name"
  default     = "app-key"
}

variable "app_filename" {
  type        = string
  description = "Path where app files is placed"
}