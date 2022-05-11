data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "172.17.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "rails-apprunner-VPC"
  }
}

resource "aws_subnet" "private" {
  count             = "2"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    Name = "rails-apprunner-PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count                   = "2"
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Name = "rails-apprunner-PublicSubnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rails-apprunner-IGW"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "eip" {
  count      = "2"
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "rails-apprunner-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         ="2"
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  tags = {
    Name = "rails-apprunner-NatGateway-${count.index + 1}"
  }
}

resource "aws_route_table" "private-route-table" {
  count  = "2"
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = {
    Name = "rails-apprunner-PrivateRouteTable-${count.index + 1}"
  }
}

resource "aws_route_table_association" "route-association" {
  count          = "2"
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}