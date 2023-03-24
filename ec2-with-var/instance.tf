resource "aws_instance" "baytera-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1
  key_name               = "new-baytera-key"
  vpc_security_group_ids = ["sg-0a5f5e49e1215fa97"]
  tags = {
    Name    = "Baytera-Instance"
    Project = "Baytera"
  }

}