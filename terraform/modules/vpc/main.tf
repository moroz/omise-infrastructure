resource "aws_vpc" "_" {
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = "10.0.0.0/16"

  tags = {
    Name = "${var.namespace}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                                         = aws_vpc._.id
  cidr_block                                     = "10.0.0.0/24"
  ipv6_cidr_block                                = cidrsubnet(aws_vpc._.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation                = true
  availability_zone                              = var.availability_zones[0]
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = {
    Name = "${var.namespace}-public-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc._.id
}

resource "aws_default_route_table" "_" {
  default_route_table_id = aws_vpc._.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gateway.id
  }
}

resource "aws_subnet" "private" {
  vpc_id                                         = aws_vpc._.id
  cidr_block                                     = "10.0.1.0/24"
  ipv6_cidr_block                                = cidrsubnet(aws_vpc._.ipv6_cidr_block, 8, 2)
  assign_ipv6_address_on_creation                = true
  availability_zone                              = var.availability_zones[1]
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = {
    Name = "${var.namespace}-private-subnet"
  }
}
