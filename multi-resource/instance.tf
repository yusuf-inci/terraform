resource "aws_key_pair" "bay-key" {
  key_name   = "baykey"
  public_key = file(var.PUB_KEY)
}

resource "aws_instance" "baytera-web" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.baytera-pub-1.id
  key_name               = aws_key_pair.bay-key.key_name
  vpc_security_group_ids = [aws_security_group.baytera_stack_sg.id]
  tags = {
    Name = "my-baytera"
  }
}

resource "aws_ebs_volume" "vol_4_baytera" {
  availability_zone = var.ZONE1
  size              = 3
  tags = {
    Name = "extr-vol-4-baytera"
  }
}

resource "aws_volume_attachment" "atch_vol_baytera" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.vol_4_baytera.id
  instance_id = aws_instance.baytera-web.id
}

output "PublicIP" {
  value = aws_instance.baytera-web.public_ip
}

