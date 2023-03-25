resource "aws_key_pair" "baytera-key" {
    key_name = "baytera"
    public_key = file("baytera.pub")
}

resource "aws_instance" "baytera-inst" {
    ami = var.AMIS[var.REGION]
    instance_type = "t2.micro"
    availability_zone = var.ZONE1
    key_name = aws_key_pair.baytera-key.key_name
    vpc_security_group_ids = ["sg-0a5f5e49e1215fa97"]
    tags = {
        Name    = "Baytera-Instance"
        Project = "Baytera"
    }

    provisioner "file" {
        source = "web.sh"
        destination = "/tmp/web.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod u+x /tmp/web.sh",
            "sudo /tmp/web.sh"
        ]
    }

    connection {
        user = var.USER
        private_key = file("baytera")
        host = self.public_ip 
      
    }
}