# terragrunt/terragrunt.hcl

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "tgshowcase-terraform-state-bucket"
    region         = "eu-west-1"
    key            = "terragrunt/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terragrunt-tf-lock"
  }
}

inputs = {
  # Default capacities for DynamoDB
  dynamodb_read_capacity  = 1
  dynamodb_write_capacity = 1
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
  source = "${get_parent_terragrunt_dir()}/modules/simple_module"

  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "👋😊 This echo comes from terragrunt's before_hook, edit me to run real commands before terraform apply/plan"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "🙋 Finished running Terraform with Terragrunt, cheers!"]
    run_on_error = true
  }
}
