# Terragrunt Demo

This repository was created to showcase some of the powers that [Terragrunt](https://terragrunt.gruntwork.io/) adds to plain Terraform.

Terragrunt is a wrapper that provides extra tools for working with Terraform configurations, helping manage and maintain Terraform code more effectively. You can keep using the same te

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
    │   ├── client1.hcl          # Client-level configuration
    │   ├── dev/
    │   │   └── terragrunt.hcl      # Environment-level configuration (dev)
    │   └── pro/
    │       └── terragrunt.hcl      # Environment-level configuration (pro)
    └── client2/
        ├── client2.hcl          # Client-level configuration
        ├── dev/
        │   └── terragrunt.hcl      # Environment-level configuration (dev)
        └── pro/
            └── terragrunt.hcl      # Environment-level configuration (pro)
    ```

    There are no `backend.tf` files! If you take a peak at the environment `terragrunt.hcl` you will see that values like the client's name are inherited instead of repeated.

3. Navigate to the `terraform/client1/dev` folder and run a `terraform init`. The bucket and the dynamo table do not exist, you have to create them manually to store the state.

4. Now open `terragrunt/client1/dev/terragrunt.hcl`: there is no backend bucket defined in there.

5. Go look and look for it inside `terragrunt/terragrunt.hcl`. Then check that the state bucket `tgshowcase-terraform-state-bucket` does not exist in your account (https://eu-west-1.console.aws.amazon.com/s3/home?region=eu-west-1).

6. Let's try to run `terragrunt plan` at `terragrunt/client1/dev`. Allow terragrunt to create the s3 bucket.

7. Observe how the [DynamoDB table](https://eu-west-1.console.aws.amazon.com/dynamodbv2/home?region=eu-west-1#table?name=terragrunt-tf-lock) was created together with the bucket.

8. If you take a look at the logs, you will see one echo command was executed before the plan and another was executed after it.

9. Navigate to the root of the `terragrunt` directory and run `terragrunt run-all plan`. All environment plans ran with only one command!



## Some examples of how Terragrunt extends Terraform

Terragrunt is a thin wrapper around Terraform that provides extra tools for keeping your configurations DRY (Don't Repeat Yourself), managing remote state, handling dependencies, and working efficiently with multiple environments. If you do not have the time to [read the documentation](https://terragrunt.gruntwork.io/docs/), here is a brief explanation of **some** useful features:

### 1. Dividing state into smaller pieces

**Problem with large state files:**

- **Complexity:** A large Terraform state file can become difficult to manage and understand.
- **Concurrency issues:** Team members may encounter locking issues when working on different parts of the infrastructure simultaneously.
- **Risk of errors:** Changes in one part of the configuration can inadvertently affect unrelated resources.

**Terragrunt solution:**

- **Modularization:** Encourages splitting your infrastructure into smaller, focused modules, each with its own state file.
- **Isolation:** By organizing infrastructure into separate components (e.g., VPC, databases, applications), you reduce the blast radius of changes and improve collaboration.

---

### 2. Managing dependencies between modules

**Problem:**

- Terraform lacks native support for orchestrating the execution order of separate modules with their own state files.
- Outputs from one module may be required as inputs in another, complicating automation.

**Terragrunt solution:**

- **dependency blocks:** Define dependencies between modules, allowing Terragrunt to automatically manage the execution order and pass outputs.

- **`run-all` command:** Execute Terraform commands across multiple modules, respecting dependencies.

**Example:**


```hcl
# terragrunt.hcl for an application module that depends on the vpc one
include {
    path = "${get_repo_root()}/terragrunt.hcl"
}

dependencies {
    paths = ["../vpc"]
}

dependency "vpc" {
    config_path = "../vpc"
}

inputs = {
    vpc_id = dependency.vpc.outputs.vpc_id
}
```

```bash
# Deploy all modules in the correct order
$ terragrunt run-all apply
```

---

### 3. Utilizing Terragrunt built-in functions

**Some useful functions:**

- **`get_repo_root()`:** Returns the root directory of your repository, useful for constructing paths.
- **`run_cmd()`:** Runs a shell command and returns the stdout as the result of the interpolation.
- **`get_aws_account_id()`:** Returns the id of the account.

> More at https://terragrunt.gruntwork.io/docs/reference/built-in-functions/

**Example:**

```hcl
# Using get_repo_root() to reference a module
terraform {
    source = "\${get_repo_root()}/modules/ecs-service"
}
```

---

### 4. Centralized remote backend configuration

**Problem:**

- Repeating backend configurations (like S3 bucket details) in every module leads to duplication and potential inconsistencies.

**Terragrunt solution:**

- **Root-level configuration:** Define backend settings once at the root, and inherit them in all child modules.

**Example:**

```hcl
# terragrunt.hcl at the root of the repository
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
```

- Child modules automatically inherit the remote state configuration:

```hcl
# Child terragrunt.hcl
include {
    path = find_in_parent_folders()
}
```

**Benefit:**

- **Consistency:** Ensures all modules use the same backend configuration without repetition.
- **Maintainability:** Updates to backend settings are made in a single place.

---

### 5. Handling multiple environments and clients efficiently

**Problem:**

- Managing configurations for multiple environments (dev, staging, prod) and clients can lead to code duplication.

**Terragrunt solution:**

- **Hierarchical configuration:** Use Terragrunt's `include` and `dependency` features to share and override configurations at different levels (root, client, environment).

**Example:**

```hcl
# terragrunt/client1/dev/terragrunt.hcl

include {
    path = find_in_parent_folders()  # loads terragrunt/terragrunt.hcl and inherits all of its inputs
}

locals {
    parent_config = read_terragrunt_config(find_in_parent_folders("client1.hcl")) # loads terragrunt/client1/client1.hcl
}

inputs = {
    bucket_name  = "${local.parent_config.locals.client_name}-dev-bucket"
    table_name   = "${local.parent_config.locals.client_name}-dev-table"
}
```

**Benefit:**

- **Reduced duplication:** Common settings are defined once and inherited.
- **Flexibility:** Environment-specific overrides are still possible.

---

### 7. Hooks for pre and post-processing

**Problem:**

- Need to perform actions before or after Terraform commands, such as validating configurations or cleaning up / building resources.

**Terragrunt solution:**

- **Before and After Hooks:** Define custom commands to run at specific stages.

**Example:**

```hcl
terraform {
    before_hook "pre_apply" {
        commands = ["apply"]
        execute  = ["echo", "About to apply configuration"]
    }

    after_hook "post_apply" {
        commands = ["apply"]
        execute  = ["echo", "Applied configuration successfully"]
    }
}
```

**Benefit:**

- Avoid writing terraform code to handle code and resources that are not IaC.

---

### 8. Keep Your CLI Flags DRY

**Problem:**

- Repeating the same CLI flags (e.g., `-var-file`, `-backend-config`) for every command can be tedious.

**Terragrunt solution:**

- **CLI Flag Inheritance:** Define CLI flags common to one or more commands and inherit avoid mistakes and headaches.

**Example:**

```hcl
terraform {
# Force Terraform to keep trying to acquire a lock for up to 20 minutes if someone else already has the lock
    extra_arguments "retry_lock" {
        commands = [
        "plan",
        "apply"
        ]
        arguments = ["-lock-timeout=20m"]
    }
}
```
