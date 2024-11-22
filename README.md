# Terragrunt Demo

This repository was created to showcase some of the powers that [Terragrunt](https://terragrunt.gruntwork.io/) adds to plain Terraform.

## Prerequisites
- Some experience with terraform
- [AWS Account that can be managed by terraform](https://banhawy.medium.com/3-ways-to-configure-terraform-to-use-your-aws-account-fb00a08ded5)
- [Terraform installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Terragrunt installed](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## Understanding the power of Terragrunt: showcase_config_tree

1.  Navigate to `showcase_config_tree/terraform` and look that we have one `backend.tf` file in each client environment. Take a look at the content of the `.tf` files, configuration is very similar between and environments and clients. Each client environment has to define all values, even if they are shared between environments or common between clients!

```
├── client1
│   ├── dev
│   │   ├── backend.tf
│   │   └── main.tf
│   └── pro
│       ├── backend.tf
│       └── main.tf
├── client2
│   ├── dev
│   │   ├── backend.tf
│   │   └── main.tf
│   └── pro
│       ├── backend.tf
│       └── main.tf
└── modules
    └── simple_module
        ├── main.tf
        └── outputs.tf
```

2.  Now look at the `showcase_config_tree/terragrunt`:
```
terragrunt/
├── terragrunt.hcl              # Root-level configuration
├── modules/
│   └── simple_module/          # Terraform module
├── client1/
│   ├── terragrunt.hcl          # Client-level configuration
│   ├── dev/
│   │   └── terragrunt.hcl      # Environment-level configuration (dev)
│   └── pro/
│       └── terragrunt.hcl      # Environment-level configuration (pro)
└── client2/
    ├── terragrunt.hcl          # Client-level configuration
    ├── dev/
    │   └── terragrunt.hcl      # Environment-level configuration (dev)
    └── pro/
        └── terragrunt.hcl      # Environment-level configuration (pro)
```

There are no `backend.tf` files! If you take a peak at the environment `terragrunt.hcl` you will see that values like the client's name are inherited instead of repeated.

2. Navigate to the `terraform/client1/dev` folder and run a `terraform init`. The bucket and the dynamo table do not exist, you have to create them manually to store the state.

3. Now open `terragrunt/client1/dev/terragrunt.hcl`: there is no backend bucket defined in there.

4. Go look and look for it inside `terragrunt/client1/dev/terragrunt.hcl`. Then check that the state bucket `tgshowcase-terraform-state-bucket` does not exist in your account (https://eu-west-1.console.aws.amazon.com/s3/home?region=eu-west-1).

5. Let's try to run `terragrunt plan` at `terragrunt/client1/dev`. Allow terragrunt to create the s3 bucket.

6. Observe how the [DynamoDB table](https://eu-west-1.console.aws.amazon.com/dynamodbv2/home?region=eu-west-1#table?name=terragrunt-tf-lock) was created together with the bucket.

7. If you take a look at the logs, you will see one echo command was executed before the plan and another was executed after it.

8. Navigate to the root of the `terragrunt` directory and run `terragrunt run-all plan`. All environment plans ran with only one command!
