resource "aws_iam_user" "new_user" {
  name = "new_user"
}


resource "aws_iam_access_key" "my_access_key" {
  user = aws_iam_user.new_user.name
  pgp_key = var.pgp_key
}

variable "key_path" {
description = "Key path for SSHing into EC2"
default  = "./terraform.pem"
}

variable "key_name" {
description = "Key name for SSHing into EC2"
default = "terraform"
}


resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
  description = "Allow SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}


resource "aws_instance" "ubuntu" {
  key_name = "${var.key_name}"
  ami           = "ami-00bf4ae5a7909786c"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key")
    host        = self.public_ip
  }

}

resource "aws_eip" "ubuntu" {
  vpc      = true
  instance = aws_instance.ubuntu.id
}
