terraform {
  backend "s3" {
    bucket = "baytera-state"
    key    = "terraform/backend_multi_resource"
    region = "us-east-2"
  }
}