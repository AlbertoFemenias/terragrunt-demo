# terragrunt/client1/pro/terragrunt.hcl

include {
  path = find_in_parent_folders()
}

locals {
  parent_config = read_terragrunt_config(find_in_parent_folders("client1.hcl"))
}

inputs = {
  bucket_name             = "${local.parent_config.locals.client_name}-pro-bucket"
  table_name              = "${local.parent_config.locals.client_name}-pro-table"
  dynamodb_write_capacity = 4
}
