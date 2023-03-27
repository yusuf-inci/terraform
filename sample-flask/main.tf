provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "baytera-key" {
  key_name   = "baytera-key"
  public_key = file("~/.ssh/baytera-key.pub")
}

resource "aws_security_group" "baytera-sg" {
  name_prefix = "baytera-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["your_ip_address/32"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["your_ip_address/32"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["your_ip_address/32"]
  }
}

resource "aws_instance" "baytera-inst" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.baytera-key.key_name
  security_groups = [aws_security_group.baytera-sg.name]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/baytera-key")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./app.py"
    destination = "/home/ec2-user/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo amazon-linux-extras install -y python3.8",
      "sudo yum -y install python3-pip",
      "sudo python3 -m pip install flask",
      "sudo python3 /home/ec2-user/app.py &"
    ]
  }

  tags = {
    Name = "baytera-instance"
  }
}

output "public_ip" {
  value = aws_instance.baytera-inst.public_ip
}
