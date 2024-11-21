provider "aws" {
  region = "eu-west-1"
}

module "simple_module" {
  source                  = "../../modules/simple_module"
  bucket_name             = "client2-pro-bucket"
  table_name              = "client2-pro-table"
  dynamodb_read_capacity  = 2
  dynamodb_write_capacity = 2
}
