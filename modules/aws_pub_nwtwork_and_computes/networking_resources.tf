## VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.name_prefix}_vpc"
  }
}

## IG
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name_prefix}_ig"
  }
}

## Subnet
resource "aws_subnet" "pub_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.pub_subnet_cidr}"
  availability_zone = "ap-northeast-1a"

  tags {
    Name = "${var.name_prefix}_pub_subnet"
  }
}

## Route Table
resource "aws_route_table" "pub_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "${var.public_cidr_block}"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags {
    Name = "${var.name_prefix}_pub_rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.pub_subnet.id}"
  route_table_id = "${aws_route_table.pub_rt.id}"
}

## Security Group
resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    protocol   = -1 
    cidr_blocks = ["${var.public_cidr_block}"]
    from_port  = 0 
    to_port    = 0 
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  # IPSEC 
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  tags {
    Name = "${var.name_prefix}_pub_sg"
  }
}

# Network ACL
resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    protocol   = "icmp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = -1
    to_port    = -1
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 500
    to_port    = 500
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 4500
    to_port    = 4500
  }

  ingress {
    protocol   = "udp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 500
    to_port    = 500
  }

  ingress {
    protocol   = "udp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 4500
    to_port    = 4500
  }

  egress {
    protocol   = -1 
    rule_no    = 700
    action     = "allow"
    cidr_block = "${var.public_cidr_block}"
    from_port  = 0
    to_port    = 0 
  }


  tags = {
    Name = "${var.name_prefix}_network_acl"
  }
}
