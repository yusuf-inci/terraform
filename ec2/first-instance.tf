provider "aws" {
  region = "us-east-2"
  # access_key = "" give credentials through awscli
  # secret_key = ""

}

resource "aws_instance" "intro" {
  ami                    = "ami-0533def491c57d991"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-2a"
  key_name               = "baytera-key"
  vpc_security_group_ids = ["sg-0a5f5e49e1215fa97"]
  tags = {
    Name    = "Baytera-Instance"
    Project = "Baytera"
  }
}