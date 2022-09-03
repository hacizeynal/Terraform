provider "aws" {
  # No need to add since we have added all configuration including region,access_key and secret_access_key via aws configure list command 
  # it is located at ~/.aws/credentials
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availibility_zone" {}
variable "env_prefix" {}
variable "my_source_ip" {}
variable "instance_type" {}
variable "my_public_key_location" {}
variable "ssh_private_key" {}
variable "user_name" {}
variable "env_prefix_dev" {}

resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true # enables public DNS
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my_app_subnet-1" {
  vpc_id = aws_vpc.my_app_vpc.id
  cidr_block = var.subnet_cidr_block 
  availability_zone = var.availibility_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet-1"
  } 
}

resource "aws_internet_gateway" "my_vpc_internet_gateway" {
     vpc_id = aws_vpc.my_app_vpc.id
     tags = {
     "Name" = "${var.env_prefix}-internet-gateway"}
}


resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.my_app_vpc.default_route_table_id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.my_vpc_internet_gateway.id
   }
   tags = {
     "Name" = "${var.env_prefix}-main-route-table"
   }
}


resource "aws_security_group" "my_app_sg" {
  name        = "allow_ssh_http"
  description = "Allow Inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.my_app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_source_ip]
  }

    ingress {
    description      = "HTTP from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # any protocol
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
     "Name" = "${var.env_prefix}-sg"
   }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh-key"
  public_key = file(var.my_public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  availability_zone = var.availibility_zone

  subnet_id =aws_subnet.my_app_subnet-1.id 
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}

resource "aws_instance" "myapp-server-two" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  availability_zone = var.availibility_zone

  subnet_id =aws_subnet.my_app_subnet-1.id 
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}


resource "aws_instance" "myapp-server-three" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"
  availability_zone = var.availibility_zone

  subnet_id =aws_subnet.my_app_subnet-1.id 
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    "Name" = "${var.env_prefix_dev}-server"
  }
}

resource "aws_instance" "myapp-server-four" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"
  availability_zone = var.availibility_zone

  subnet_id =aws_subnet.my_app_subnet-1.id 
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    "Name" = "${var.env_prefix_dev}-server"
  }
}

output "ec2_public_ip_1" {
    value = aws_instance.myapp-server.public_ip
}

output "ec2_public_ip_2" {
    value = aws_instance.myapp-server-two.public_ip
}

output "ec2_public_ip_3" {
    value = aws_instance.myapp-server-three.public_ip
}

output "ec2_public_ip_4" {
    value = aws_instance.myapp-server-four.public_ip
}
