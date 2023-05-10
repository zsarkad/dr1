resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
 
  tags = {
    Name        = "${var.project}-vpc"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
 
  tags = {
    Name        = "${var.project}-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}
 
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
 
  tags = {
    Name        = "${var.project}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
 
  tags = {
    Name        = "${var.project}-igw"
    Environment = "${var.environment}"
  }
}

/* Route Table for IG  */
resource "aws_route_table" "internet_gw_rt" {
 vpc_id = aws_vpc.vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gw.id
 }
 
 tags = {
   Name = "${var.project}-igw_rt"
   Environment = "${var.environment}"
 }
}

/* IG Association for Public Subnet */
resource "aws_route_table_association" "public_subnet_assoc" {
 count = length(var.public_subnets_cidr)
 subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
 route_table_id = aws_route_table.internet_gw_rt.id
}
 
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gw]
 tags = {
   Name        = "${var.project}-nat-eip"
   Environment = "${var.environment}"
 }  
}
 
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.internet_gw]
 
  tags = {
    Name        = "${var.project}-nat"
    Environment = "${var.environment}"
  }
}
/* Route Table for NAT */
resource "aws_route_table" "nat_gw_rt" {
   vpc_id = aws_vpc.vpc.id
   route {
   cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.nat.id
   }
 tags = {
   Name = "${var.project}-nat-rt"
   Environment = "${var.environment}"
 }
 }

/* NAT ASsociation for Private Subnet */
resource "aws_route_table_association" "private_subnet_assoc" {
 count = length(var.private_subnets_cidr)
 subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
 route_table_id = aws_route_table.nat_gw_rt.id
}

/* Security Group */
resource "aws_security_group" "sg_common" {

  name = "sec-group-common"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output any"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-public-sg"
    Environment = "${var.environment}"
  }
}
