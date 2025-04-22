output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "private_rtb_assoc_ids" {
  value = aws_route_table_association.private_subnet_association[*].id
}