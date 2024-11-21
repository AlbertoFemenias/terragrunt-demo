include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_prefix           = "client2"
  table_prefix            = "client2"
  dynamodb_read_capacity  = 1
  dynamodb_write_capacity = 1
}
