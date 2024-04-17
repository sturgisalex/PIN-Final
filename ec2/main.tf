

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "server_mse" {
  ami = data.aws_ami.ubuntu.id
  #ami ="" no
  instance_type = "t2.micro"
  #name          = "prueba-mse"
  vpc_security_group_ids = [aws_security_group.mse_vpc.id]
  key_name               = "mse_keypair"
  user_data = "${file("install_soft.sh")}"
  tags = {
    name = "mse-server"
  }
  #user_data              = var.ec2_user_data
}
output "public_ip" {
  value = aws_instance.server_mse.public_ip
}


resource "aws_security_group" "mse_vpc" {
  name        = "VPC mse"
  description = "Allow inbound traffic"
  tags = {
    name = "Mse security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

# 