resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_classiclink = "false"
  enable_dns_support = "true"
  # set this to false if you need specific dns names and your own DNS server
  enable_dns_hostnames = "true"

  tags = {
    Name = "ec2-ansible-test-vpc"
    createdBy = "edu-aws"
  }
}
resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "ec2-ansible-test-vpc"
    createdBy = "edu-aws"
  }
}
resource "aws_internet_gateway" "test_internet_gateway" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
      Name = "ec2-ansible-test-ig"
      createdBy = "edu-aws"
    }
}
resource "aws_route_table" "test_route_table" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test_internet_gateway.id}"
  }
  tags = {
      Name = "ec2-ansible-test-route-table"
      createdBy = "edu-aws"
  }
}
resource "aws_route_table_association" "test_subnet_association" {
  subnet_id      = "${aws_subnet.test_subnet.id}"
  route_table_id = "${aws_route_table.test_route_table.id}"
}
resource "aws_security_group" "test_allow_ssh_sg" {
  name = "allow-ssh-sg"
  vpc_id = "${aws_vpc.test_vpc.id}"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  tags = {
    createdBy = "edu-aws"
  }
}
resource "aws_security_group" "test_allow_icmp_sg" {
  name = "allow-icmp-sg"
  vpc_id = "${aws_vpc.test_vpc.id}"
  ingress {
    cidr_blocks = ["${aws_subnet.test_subnet.cidr_block}"]
    protocol = "ICMP"
    from_port = 8
    to_port = 0
  }
  egress {
    protocol = "ICMP"
    cidr_blocks = ["0.0.0.0/0","${aws_subnet.test_subnet.cidr_block}"]
    from_port = 8
    to_port = 0
  }
  tags = {
    createdBy = "edu_aws"
  }
}
