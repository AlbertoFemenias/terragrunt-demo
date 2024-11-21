terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "client2/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}
