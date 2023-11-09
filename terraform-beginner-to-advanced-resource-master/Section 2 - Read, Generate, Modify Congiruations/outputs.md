provider "aws" {
  region = var.region
}

variable "region" {
    default = "us-east-1"
}
variable "useast1_ami" {
    default = "ami-05c13eab67c5d8861"
}

resource "aws_iam_user" "lb" {
    name = "iamuser.${count.index}"
    count = 3
    path = "/system/"
}

output "iam_names" {
    value = aws_iam_user.lb[*].name
}

output "iam_arn" {
    value = aws_iam_user.lb[*].arn
  
}