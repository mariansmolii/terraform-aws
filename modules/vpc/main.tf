resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rtb"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_eip" "nat_eip" {
  count      = local.nat_gateway_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway" {
  count             = local.nat_gateway_count
  allocation_id     = aws_eip.nat_eip[count.index].id
  subnet_id         = aws_subnet.public[count.index].id
  connectivity_type = var.nat_connection_type
  depends_on        = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "private_rtb" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  depends_on = [aws_nat_gateway.nat_gateway]
  
  tags = {
    Name = "${var.environment}-private-rtb-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = var.enable_nat ? length(var.private_subnet_cidr) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private_rtb[*].id, count.index % max(length(aws_route_table.private_rtb), 1))
}