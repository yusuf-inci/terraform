provider "aws" {
  region     = "us-east-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

resource "aws_instance" "myec2" {
    ami = "ami-01bc990364452ab3e"
    instance_type = "t2.micro"

    tags = {
      Name = "my-first-ec2"
    }
  
}
