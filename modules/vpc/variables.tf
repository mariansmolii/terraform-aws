variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support"
  default     = true
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "nat_count" {
  type        = number
  description = "Number of NAT gateways to create"
  default     = 1
}

variable "nat_connection_type" {
  type        = string
  description = "Type of NAT connection"
  default     = "public"
}