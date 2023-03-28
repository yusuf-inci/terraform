variable "REGION" {
  default = "us-east-2"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "ZONE2" {
  default = "us-east-2b"
}

variable "ZONE3" {
  default = "us-east-2c"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-2 = "ami-0533def491c57d991"
    us-east-1 = "ami-04581fbf744a7d11f"
  }
}

variable "USER" {
  default = "ec2-user"
}

variable "PUB_KEY" {
  default = "baykey.pub"
}

variable "PRIV_KEY" {
  default = "baykey"
}

variable "MYIP" {
  default = "78.170.81.8/32"
}
