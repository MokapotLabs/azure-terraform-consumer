#!/usr/bin/env bash
set -euo pipefail

TENANT_ID="8b731c9d-8de8-4138-9a48-c62bd34696f2"
SUBSCRIPTION_ID="4d110979-de81-47ca-ae8e-6eb3494bcf2e"

HCP_ORG="mbarcia"
HCP_PROJECT_NAME="Azure-Terraform example"
HCP_STACK="azure-terraform-consumer"

create_env() {
  local ENV_NAME="$1"
  local APP_NAME="tfstacks-azure-example-${ENV_NAME}"

  az account set --subscription "$SUBSCRIPTION_ID"

  CLIENT_ID="$(az ad app create \
    --display-name "$APP_NAME" \
    --query appId -o tsv)"

  APP_OBJECT_ID="$(az ad app show \
    --id "$CLIENT_ID" \
    --query id -o tsv)"

  az ad sp create --id "$CLIENT_ID" >/dev/null

  sleep 15

  SP_OBJECT_ID="$(az ad sp show \
    --id "$CLIENT_ID" \
    --query id -o tsv)"

  az role assignment create \
    --assignee-object-id "$SP_OBJECT_ID" \
    --assignee-principal-type ServicePrincipal \
    --role Contributor \
    --scope "/subscriptions/$SUBSCRIPTION_ID"

  cat > "fic-${ENV_NAME}-plan.json" <<EOF
{
  "name": "${ENV_NAME}-plan",
  "issuer": "https://app.terraform.io",
  "subject": "organization:${HCP_ORG}:project:${HCP_PROJECT_NAME}:stack:${HCP_STACK}:deployment:${ENV_NAME}:operation:plan",
  "description": "HCP Terraform Stacks ${ENV_NAME} plan",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

  az ad app federated-credential create \
    --id "$APP_OBJECT_ID" \
    --parameters @"fic-${ENV_NAME}-plan.json"

  cat > "fic-${ENV_NAME}-apply.json" <<EOF
{
  "name": "${ENV_NAME}-apply",
  "issuer": "https://app.terraform.io",
  "subject": "organization:${HCP_ORG}:project:${HCP_PROJECT_NAME}:stack:${HCP_STACK}:deployment:${ENV_NAME}:operation:apply",
  "description": "HCP Terraform Stacks ${ENV_NAME} apply",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

  az ad app federated-credential create \
    --id "$APP_OBJECT_ID" \
    --parameters @"fic-${ENV_NAME}-apply.json"

  echo
  echo "Set these in HCP Terraform:"
  echo "${ENV_NAME}_client_id=$CLIENT_ID"
  echo "${ENV_NAME}_tenant_id=$TENANT_ID"
  echo "${ENV_NAME}_subscription_id=$SUBSCRIPTION_ID"
}

az login
az account set --subscription "$SUBSCRIPTION_ID"

create_env dev
create_env prod
