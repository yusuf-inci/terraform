resource "aws_security_group" "baytera_stack_sg" {
  vpc_id      = aws_vpc.baytera.id
  name        = "baytera-stack-sg"
  description = "Sec Grp for baytera ssh"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }
  tags = {
    Name = "allow-ssh-myip"
  }
}