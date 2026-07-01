terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc"{
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Production_vpc"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet_Gateway"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.0.0/24"
}

resource "aws_route_table" "aws_RT" {
  vpc_id = aws_vpc.vpc.id
  
}

resource "aws_route" "route" {
  route_table_id = aws_route_table.aws_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.IGW.id
}

resource "aws_route_table_association" "aws_RT_ass" {
  route_table_id = aws_route_table.aws_RT.id
  subnet_id = aws_subnet.public_subnet.id
}


resource "aws_security_group" "SG_group" {
  name = "AWS security group"
  description = "SG group VPC"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "SG Group for vpc"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.SG_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8080
  ip_protocol = "tcp"
  to_port = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ssh_group" {
  security_group_id = aws_security_group.SG_group.id
  cidr_ipv4 = "212.58.102.17/32"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.SG_group.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}


resource "aws_instance" "ec2_machine" {
  ami = "ami-0a1f442aef5d95cfd"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.SG_group.id]
  key_name = "terraform"
  associate_public_ip_address = true
  instance_type = "m7i-flex.large"

}
# resource "aws_instance" "ec2" {
#   ami = "ami-0c541e8575db12991"
#   instance_type = "t3.micro"
# }