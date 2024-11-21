include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_name = "${include.locals.bucket_prefix}-dev-bucket"
  table_name  = "${include.locals.table_prefix}-dev-table"
}
