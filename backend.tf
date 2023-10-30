terraform {
  backend "s3" {
    bucket = "mikes-terraform-state"
    key    = "mikes-cluster.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}
