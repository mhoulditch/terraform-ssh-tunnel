provider "aws" {
  region     = var.awsregion
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic for terrassh use"
  ingress {
    description = "ssh inbound from anyhwere"
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "terrassh" {
  key_name = "terrassh"
  public_key = file("~/.ssh/terrassh.pub")
} 

resource "aws_instance" "terrassh" {
  key_name = aws_key_pair.terrassh.key_name  
  ami           = var.ami
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  tags = {
    Name = "terra-ssh"
  }
}
output "instance_ip_addr" {
  value = aws_instance.terrassh.public_ip
}
output "instance_ssh_key" {
  value = aws_instance.terrassh.key_name
}

