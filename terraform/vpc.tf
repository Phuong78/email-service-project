resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = "${var.project_name}-VPC"
    Project   = var.project_name
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name      = "${var.project_name}-IGW"
    Project   = var.project_name
    Terraform = "true"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true                                           # Tự động gán Public IP cho instance trong subnet này
  availability_zone       = data.aws_availability_zones.available.names[0] # Sử dụng AZ đầu tiên khả dụng

  tags = {
    Name      = "${var.project_name}-Public-Subnet"
    Project   = var.project_name
    Terraform = "true"
  }
}

#data "aws_availability_zones" "available" {} # Lấy danh sách các AZ khả dụng trong vùng

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name      = "${var.project_name}-Public-RouteTable"
    Project   = var.project_name
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}