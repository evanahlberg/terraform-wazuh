provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/Users/Evan.Ahlberg/.aws/config"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = "172.30.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "Wazuh Lab"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "172.30.0.0/24"

  tags = {
    Name = "Wazuh Lab Subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Wazuh Internet Gateway"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Wazuh Route Table"
  }
}

resource "aws_route_table_association" "main_rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_security_group" "win_sg" {
  name        = "Wazuh Windows"
  description = "Wazuh Windows Lab"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  ingress {
    description = "RDP from Internet"
    from_port   = "3389"
    to_port     = "3389"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
  }

  tags = {
    Name = "Wazuh Windows SG"
  }
}

resource "aws_security_group" "linux_sg" {
  name        = "Wazuh Linux"
  description = "Wazuh Linux Lab"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  ingress {
    description = "SSH from Internet"
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = "443"
    to_port     = "443"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
  }

  tags = {
    Name = "Wazuh Linux SG"
  }
}