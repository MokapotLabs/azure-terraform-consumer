# Azure Terraform Consumer Stack

This repository is the thin Stack that provisions the live `dev` and `prod` Azure environments by consuming the published component configuration from the HCP Terraform private registry.

## What This Repo Does

- references the published component with a `stack` block
- defines two deployments, `dev` and `prod`
- uses HCP Terraform workload identity tokens for Azure authentication
- keeps runtime values and rollout ownership separate from the published component source

## Files

```text
.
├── .terraform-version
├── main.tfcomponent.hcl
├── variables.tfcomponent.hcl
├── deployments.tfdeploy.hcl
├── security.sh
└── README.md
```

## Published Component Source

This consumer Stack is configured to use the published component source:

```hcl
source = "app.terraform.io/mbarcia/azure-terraform-example"
version = "2.3.1"
```

If you publish a newer component release, update [main.tfcomponent.hcl](/Users/mari/mokapot/azure-terraform-consumer/main.tfcomponent.hcl) to the new version.

## Local Validation

If you are authenticated to HCP Terraform for private registry access:

```bash
terraform stacks init
terraform stacks validate
```

If `terraform stacks init` fails with a private registry authentication or unknown source error, authenticate with HCP Terraform first and confirm the `source` address matches the published component exactly.

## HCP Terraform Setup

1. Create a new repository from this directory’s contents.
2. In HCP Terraform, create a dedicated project for live Stack deployments.
3. Create a new Stack connected to the consumer repository.
4. Create an HCP Terraform variable set named `azure-terraform-consumer`.
5. Add Terraform-category variables to that variable set:
   - `dev_client_id`
   - `dev_tenant_id`
   - `dev_subscription_id`
   - `prod_client_id`
   - `prod_tenant_id`
   - `prod_subscription_id`
   - `admin_ssh_public_key`
6. Assign that variable set to the Stack itself or to the project containing the Stack.
7. Push the repo and let HCP Terraform load the Stack configuration.

HCP Terraform will create separate deployment plans for `dev` and `prod`. Approve and apply them independently.

This is different from classic workspaces: Stack deployments read external values through `store "varset"` blocks in `*.tfdeploy.hcl`, not from a workspace-style Variables tab.

## Azure Bootstrap Helper

[security.sh](/Users/mari/mokapot/azure-terraform-consumer/security.sh) is a small helper script used to create the Azure app registrations, service principals, role assignments, and federated credentials for the `dev` and `prod` deployments. It also prints the values that must be added to the `azure-terraform-consumer` HCP Terraform variable set.

## Azure OIDC Setup

Use separate Azure app registrations or service principals for `dev` and `prod`.

For each environment:

1. Create or identify the Azure app registration.
2. Add a federated credential with:
   - Issuer: `https://app.terraform.io`
   - Audience: `api://AzureADTokenExchange`
3. Create one credential for plan and one for apply for each deployment.

Subject format for Stack deployments:

```text
organization:<ORG_NAME>:project:<PROJECT_NAME>:stack:<STACK_NAME>:deployment:<DEPLOYMENT_NAME>:operation:<OPERATION_TYPE>
```

Examples:

```text
organization:my-org:project:platform:stack:azure-terraform-consumer:deployment:dev:operation:plan
organization:my-org:project:platform:stack:azure-terraform-consumer:deployment:dev:operation:apply
organization:my-org:project:platform:stack:azure-terraform-consumer:deployment:prod:operation:plan
organization:my-org:project:platform:stack:azure-terraform-consumer:deployment:prod:operation:apply
```

Assign Azure RBAC to each app registration at the required subscription or resource group scope before applying.

## Deployment Behavior

- `dev` deploys to `eastus2` with a public IP and SSH restricted to the configured admin CIDR.
- `prod` deploys to `westeurope` without a public IP.
- Both deployments use the same published component version unless you change the version constraint.
