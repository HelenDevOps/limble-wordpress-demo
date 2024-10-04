provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "limble_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "limble-vpc"
  }
}
# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.limble_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name                                       = "limble-public-subnet"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/project-limble-eks" = "shared"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.limble_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name                                       = "limble-private-subnet"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/project-limble-eks" = "shared"
  }
}
# Private Subnet
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.limble_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name                                       = "limble-private-subnet-az1"
    "kubernetes.io/role/internal-elb"          = "1"
    "kubernetes.io/cluster/project-limble-eks" = "shared"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.limble_vpc.id
  tags = {
    Name = "limble-igw"
  }
}
# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "limble-nat-gateway"
  }
}
# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.limble_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "limble-public-route-table"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.limble_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "limble-private-route-table"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
# Security Group for WordPress (ECS/EKS)
resource "aws_security_group" "wordpress_sg" {
  vpc_id = aws_vpc.limble_vpc.id
  name   = "limble-wordpress-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "limble-wordpress-sg"
  }
}

# Security Group for RDS (MariaDB/MySQL)
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.limble_vpc.id
  name   = "limble-rds-sg"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.wordpress_sg.id
    ] # Allow DB traffic only from WordPress ECS/EKS security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "limble-rds-sg"
  }
}
