# terragrunt/client2/dev/terragrunt.hcl

include {
  path = find_in_parent_folders()
}

locals {
  parent_config = read_terragrunt_config(find_in_parent_folders("client2.hcl"))
}

inputs = {
  bucket_name             = "${local.parent_config.locals.client_name}-dev-bucket"
  table_name              = "${local.parent_config.locals.client_name}-dev-table"
}
