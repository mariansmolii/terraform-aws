resource "aws_security_group" "this" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-${var.sg_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  security_group_id = aws_security_group.this.id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = each.value.ip_protocol

  referenced_security_group_id = try(each.value.source_sg_id, null)
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}