terraform {
  backend "s3" {
    bucket         = "tgshowcase_terraform-state-bucket"
    key            = "client2/pro/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}
