variable "bucket_name" {
  default = "default_bucket_name"
}
variable "table_name" {
  default = "default_table_name"
}
variable "dynamodb_read_capacity" {
  default = 1
}
variable "dynamodb_write_capacity" {
  default = 1
}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

resource "aws_dynamodb_table" "example" {
  name         = var.table_name
  billing_mode = "PROVISIONED"
  read_capacity = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"
}
