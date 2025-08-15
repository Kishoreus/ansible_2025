provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "default" {
  key_name   = "mykeypair"
  public_key = file("${path.module}/files/mykeypair.pub")
}

resource "aws_security_group" "vm_sg" {
  name        = "vm_sg"
  description = "Allow SSH"

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


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm" {
  count         = 5
  ami           = "ami-0fc5d935ebf8bc3bc" # UBUNTU
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.key_name
  security_groups = [aws_security_group.vm_sg.name]

  tags = {
    Name = "vm-${count.index + 1}"
  }
}

output "instance_public_ip" {
  description = "Public IP of the first EC2 instance"
  value       = aws_instance.vm[0].public_ip
}


