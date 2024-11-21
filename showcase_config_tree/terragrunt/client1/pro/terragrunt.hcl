include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_name            = "${include.locals.bucket_prefix}-pro-bucket"
  table_name             = "${include.locals.table_prefix}-pro-table"
  dynamodb_read_capacity = 2
  dynamodb_write_capacity = 2
}
