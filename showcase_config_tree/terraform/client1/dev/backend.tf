terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "client1/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}
