variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "sg_name" {
  type        = string
  description = "Security Group Name"
}

variable "sg_description" {
  type        = string
  description = "Security Group Description"
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    port         = number
    ip_protocol  = optional(string, "tcp")
    source_sg_id = optional(string)
    cidr_ipv4    = optional(string)
  }))
}