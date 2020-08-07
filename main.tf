provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/Users/Evan.Ahlberg/.aws/config"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "172.30.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "Wazuh Lab"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.30.0.0/24"

  tags = {
    Name = "Wazuh Lab Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Wazuh Internet Gateway"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Wazuh Route Table"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "win_sg" {
  name        = "Wazuh Windows"
  description = "Wazuh Windows Lab"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    description = "RDP from Internet"
    from_port   = "3389"
    to_port     = "3389"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Wazuh Windows SG"
  }
}

resource "aws_security_group" "linux_sg" {
  name        = "Wazuh Linux"
  description = "Wazuh Linux Lab"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    description = "SSH from Internet"
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = "443"
    to_port     = "443"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Wazuh Linux SG"
  }
}

resource "aws_key_pair" "wazuh_key" {
  key_name = "Wazuh_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCE6mGgiYjxrd3WeX0FOhcKOgcHJRk9I+7Nq7FHw9GEkxey4MCnN46qm9jegfvEBNM75S1oBsosgU/Y6P9hVnJGU+BcBnnAEaJCVAbtl1Sd8AsAom6w9GOw5+AohZgnBRYRGytRRZ0uWUSX/4qNP7gkxdeFP8OjgmMknVcZZWS2WumYeq5eq3i6xPI4C5IFVB2gvxW1qlXhkps9442SFHv/vZchRxYgcm2RLEj6GT/inD3nOkNRB7HIBWUqbeZx/pbd24CD0k9afcoQenYUqpoIecAX4DKUU3f2VQ9XkiH8ne9sxxm2gLoWSmLgw4vZ+GuTlRjAfO3XZz3NKNlUT9jJ imported-openssh-key"
}

resource "aws_instance" "wazuh_svr" {
  ami           = "ami-0affd4508a5d2481b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.linux_sg.id]
  subnet_id = aws_subnet.subnet.id
  private_ip = "172.30.0.10"
  user_data = file("userdata.sh")
  key_name = aws_key_pair.wazuh_key.key_name

  tags = {
    Name = "Wazuh Server"
  }
}

resource "aws_instance" "wazuh_elastic_svr" {
  ami           = "ami-0affd4508a5d2481b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.linux_sg.id]
  subnet_id = aws_subnet.subnet.id
  private_ip = "172.30.0.20"
  user_data = file("userdata.sh")
  key_name = aws_key_pair.wazuh_key.key_name

  tags = {
    Name = "Wazuh Elastic Server"
  }
}

resource "aws_instance" "wazuh_linux_agent" {
  ami           = "ami-0affd4508a5d2481b"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.linux_sg.id]
  subnet_id = aws_subnet.subnet.id
  private_ip = "172.30.0.30"
  user_data = file("userdata.sh")
  key_name = aws_key_pair.wazuh_key.key_name

  tags = {
    Name = "Wazuh Linux Agent"
  }
}

resource "aws_instance" "wazuh_windows_agent" {
  ami           = "ami-0f38562b9d4de0dfe"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.windows_sg.id]
  subnet_id = aws_subnet.subnet.id
  private_ip = "172.30.0.40"
  key_name = aws_key_pair.wazuh_key.key_name

  tags = {
    Name = "Wazuh Windows Agent"
  }
}