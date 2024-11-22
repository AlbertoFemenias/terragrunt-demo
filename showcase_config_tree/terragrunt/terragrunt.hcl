# terragrunt/terragrunt.hcl

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "tgshowcase-terraform-state-bucket-${get_aws_account_id()}"
    region         = "eu-west-1"
    key            = "terragrunt/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terragrunt-tf-lock"
  }
}

inputs = {
  # Default capacities for DynamoDB
  dynamodb_read_capacity  = 2
  dynamodb_write_capacity = 2
}

locals {
  aws_region = "eu-west-1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
    region  = "${local.aws_region}"
  }
EOF
}

terraform {
  # notice that leaf terragrunt.hcl are inheriting the source module
  source = "${get_parent_terragrunt_dir()}/modules/simple_module"

  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "👋😊 This echo comes from Terragrunt's before_hook, edit me to run real commands before terraform apply/plan"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "🙋 Finished running Terraform with Terragrunt, cheers!"]
    run_on_error = true
  }
}
