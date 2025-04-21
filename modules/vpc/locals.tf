locals {
  nat_gateway_count = var.enable_nat ? length(var.availability_zones) : 0
}