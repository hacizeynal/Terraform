resource "aws_security_group" "my_app_sg" {
  name        = "allow_ssh_http"
  description = "Allow Inbound SSH and HTTP traffic"
  vpc_id      = var.vpc_id

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
        values = [var.image_name]
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

  subnet_id =var.subnet_id
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = {
    "Name" = "${var.env_prefix}-server"
  }

  user_data =file("entry-script.sh")
}