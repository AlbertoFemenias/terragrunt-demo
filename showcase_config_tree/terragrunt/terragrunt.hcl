remote_state {
  backend = "s3"
  config = {
    bucket         = "tgshowcase_terraform-state-bucket"
    region         = "eu-west-1"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "tgshowcase_terraform-lock"
  }
}

locals {
  bucket_prefix = ""
  table_prefix  = ""
}
