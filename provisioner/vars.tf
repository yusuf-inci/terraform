variable "REGION" {
  default = "us-east-2"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "AMIS" {
  type = map
  default = {
    us-east-2 = "ami-0533def491c57d991"
    us-east-1 = "ami-04581fbf744a7d11f"
  }
}

variable "USER" {
    default = "ec2_user"
}


