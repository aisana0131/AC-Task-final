# Terraform Infrastructure: AWS EC2 + Okta User Management

This repository contains a complete Terraform configuration that deploys:

- An **EC2 instance** using a reusable module  
- **Okta users and group memberships** using a dedicated Okta module  
- A **root module** that orchestrates AWS + Okta + Secrets Manager  

The project follows a modular, production‑grade structure suitable for identity automation and cloud infrastructure provisioning.

---

## Repository Structure

```

├── .github/
│   ├── workflows/
│       └── centralized-apply.yaml
├── caller-workflows/
│   ├── apply-dev.yaml
│   └── apply-prod.yaml
├── design-diagrams/
│   ├── architecture.drawio.png
│   └── cicd.drawio.png
├──terraform/
│   ├──main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── ec2/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── okta-users/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .gitignore
└── README.md

```

---

# Root Module

The root module wires together AWS and Okta resources, including:

- AWS provider  
- Okta provider  
- EC2 module  
- Okta users module  
- Secrets Manager for Okta private key  

---

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.14.0 |
| aws | ~> 6.28.0 |
| okta | ~> 4.10.0 |

---

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.28.0 |
| okta | ~> 4.10.0 |

---

## Modules

| Name | Source | Version |
|------|--------|---------|
| final_ec2 | ./modules/ec2 | n/a |
| okta_users | ./modules/okta-users | n/a |

---

## Resources

| Name | Type |
|------|------|
| aws_secretsmanager_secret_version.okta_private_key | data source |

---

## Root Module Inputs

| Name | Type | Required |
|------|------|:--------:|
| ami_id | string | yes |
| environment | string | yes |
| instance_type | string | no |
| name | string | yes |
| region | string | yes |
| okta_org_name | string | yes |
| okta_base_url | string | yes |
| okta_client_id | string | yes |
| okta_private_key_id | string | yes |
| okta_scopes | list(string) | yes |
| okta_users | map(object) | yes |
| default_groups | list(string) | no |

---

# EC2 Module

A reusable module that provisions an EC2 instance.

---

## Requirements

No additional requirements.

---

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

---

## Resources

| Name | Type |
|------|------|
| aws_instance.final_ec2 | resource |

---

## Inputs

| Name | Type | Required |
|------|------|:--------:|
| ami_id | string | yes |
| environment | string | yes |
| instance_type | string | no |
| name | string | yes |

---

## Outputs

| Name |
|------|
| instance_id |
| public_ip |

---

# Okta Users Module

A module for creating Okta users and assigning them to groups.

---

## Requirements

| Name | Version |
|------|---------|
| okta | ~> 4.10.0 |

---

## Providers

| Name | Version |
|------|---------|
| okta | ~> 4.10.0 |

---

## Resources

| Name | Type |
|------|------|
| okta_user.users | resource |
| okta_user_group_memberships.memberships | resource |

---

## Inputs

| Name | Type | Required |
|------|------|:--------:|
| okta_users | map(object) | yes |

---

## Outputs

None.

---

# Example `terraform.tfvars`

```hcl
region = "us-east-1"
environment = "dev"
name = "demo-ec2"
ami_id = "ami-1234567890"
instance_type = "t2.micro"

okta_org_name       = "dev-123456"
okta_base_url       = "okta.com"
okta_client_id      = "0oa123example"
okta_private_key_id = "kid123example"

okta_scopes = [
  "okta.users.manage",
  "okta.groups.manage",
  "okta.apps.read"
]

default_groups = ["all-employees"]

okta_users = {
  alice = {
    first_name = "Alice"
    last_name  = "Johnson"
    email      = "alice.johnson@example.com"
    groups     = ["engineers"]
  }

  bob = {
    first_name = "Bob"
    last_name  = "Smith"
    email      = "bob.smith@example.com"
    groups     = ["admins", "engineers"]
  }
}
```

---

# Usage


# Usage: Centralized Reusable Workflow

This repository provides a **centralized GitHub Actions workflow** that standardizes Terraform operations across multiple caller repositories.  
The workflow encapsulates:

- OIDC authentication  
- Terraform init/plan/apply  
- Artifact upload/download  
- Environment‑specific variable handling  
- Manual approvals (optional)  
- Consistent logging and error handling  

Caller repositories only need a minimal workflow file to consume it.

---

## 1. Centralized Workflow Location

The reusable workflow lives in this repository at:

```
.github/workflows/centralized-workflow.yaml
```

This file defines all Terraform logic and is shared across multiple repos.

---

## 2. How Caller Repositories Use the Centralized Workflow

Each caller repo includes a lightweight workflow that **delegates execution** to the centralized workflow.

Example caller workflow: choose one from caller-workflows (apply-dev.yaml or apply-prod.yaml)

```yaml
name: Deploy via Centralized Terraform Workflow
on:
  push:
    branches: [dev]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    uses: aisana0131/AC-Task/.github/workflows/centralized-apply.yaml@main
    with:
      working_directory: terraform
      aws_role_arn: ${{ vars.AWS_DEV_ROLE_ARN }}
      s3_bucket: ${{vars.DEV_S3_BUCKET}}
      s3_key_prefix: prod
      aws_region: ${{ vars.AWS_REGION }}
    secrets:
      AWS_ACCOUNT_ID: ${{ secrets.DEV_AWS_ACCOUNT_ID }}
```

### What the caller workflow provides

| Input | Purpose |
|-------|---------|
| `environment` | Selects dev/stage/prod configuration |
| `terraform_directory` | Path to Terraform code in the caller repo |

### Required secrets

| Secret | Purpose |
|--------|---------|
| `AWS_ROLE_TO_ASSUME` | OIDC role for Terraform execution |
| `OKTA_PRIVATE_KEY` | Private key for Okta provider authentication |

---

## 3. What the Centralized Workflow Does

Once triggered, the centralized workflow:

### **1. Authenticates to AWS using OIDC**
- No long‑lived credentials  
- Role assumption based on repo + branch trust

### **2. Sets up Terraform**
- Downloads Terraform  
- Initializes backend  
- Configures environment variables

### **3. Runs Terraform Plan**
- Generates a plan file  
- Uploads the plan as an artifact  

### **5. Runs Terraform Apply**
- Applies the previously generated plan  

---

## 4. Example: Triggering the Workflow Manually

From GitHub UI:

1. Go to **Actions**  
2. Select **Deploy Infrastructure**  
3. Click **Run workflow**  
4. Choose environment (e.g., `dev`, `main`)  
5. Run  

The centralized workflow handles everything else.

---

## 5. Benefits of the Centralized Workflow

- **Consistency** — all repos follow the same Terraform process  
- **Security** — OIDC, no static credentials  
- **Auditability** — plans, logs, and outputs stored as artifacts  
- **Simplicity** — caller repos stay minimal  
- **Scalability** — add new repos without duplicating logic  

---

## 6. Also visit my another repo (https://github.com/aisana0131/okta-terraform.git).
