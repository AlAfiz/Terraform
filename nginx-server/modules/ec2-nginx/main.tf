resource "aws_key_pair" "nginx_key_pair" {
  key_name   = "nginx-server"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "nginx_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "nginx_subnet" {
  vpc_id                  = aws_vpc.nginx_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.nginx_vpc.id
}

resource "aws_route_table" "nginx_rt" {
  vpc_id = aws_vpc.nginx_vpc.id


  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.nginx_igw.id
  }
}

resource "aws_route_table_association" "nginx_rta" {
  route_table_id = aws_route_table.nginx_rt.id
  subnet_id      = aws_subnet.nginx_subnet.id
}


resource "aws_security_group" "nginx_server_sg" {
  name        = "nginx_sg"
  description = "Allow ssh access and http/https access"
  vpc_id      = aws_vpc.nginx_vpc.id


  #Inbound SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  #Inbound from nginx
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

}

resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_server_sg.id]
  subnet_id              = aws_subnet.nginx_subnet.id
  key_name               = aws_key_pair.nginx_key_pair.key_name

  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y && sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
docker run -d -p 8080:80 nginx
EOF


}


