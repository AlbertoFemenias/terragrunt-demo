provider "aws" {
  region = "eu-west-1"
}

module "simple_module" {
  source                  = "../../modules/simple_module"
  bucket_name             = "client1-dev-bucket"
  table_name              = "client1-dev-table"
  dynamodb_read_capacity  = 1
  dynamodb_write_capacity = 1
}
