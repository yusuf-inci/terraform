terraform {
  backend "s3" {
    bucket = "baytera-state"
    key    = "terraform/backend"
    region = "us-east-2"
  }
}