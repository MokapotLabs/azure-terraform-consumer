store "varset" "stack_vars" {
  name     = "azure-terraform-consumer"
  category = "terraform"
}

identity_token "azurerm" {
  audience = ["api://AzureADTokenExchange"]
}

deployment "dev" {
  inputs = {
    client_id               = store.varset.stack_vars.stable.dev_client_id
    tenant_id               = store.varset.stack_vars.stable.dev_tenant_id
    subscription_id         = store.varset.stack_vars.stable.dev_subscription_id
    identity_token          = identity_token.azurerm.jwt
    environment             = "dev"
    project_name            = "acme"
    location                = "eastus2"
    location_short          = "eus2"
    address_space           = ["10.10.0.0/16"]
    workload_subnet_cidr    = "10.10.1.0/24"
    private_subnet_cidr     = "10.10.2.0/24"
    admin_ssh_public_key    = store.varset.stack_vars.stable.admin_ssh_public_key
    admin_cidrs             = ["203.0.113.10/32"]
    enable_public_ip        = true
    vm_size                 = "Standard_D2ps_v6"
    admin_username          = "azureuser"
    storage_container_name  = "appdata"
    ddos_protection_plan_id = null
    extra_tags = {
      environment = "dev"
    }
  }
}

deployment "prod" {
  inputs = {
    client_id               = store.varset.stack_vars.stable.prod_client_id
    tenant_id               = store.varset.stack_vars.stable.prod_tenant_id
    subscription_id         = store.varset.stack_vars.stable.prod_subscription_id
    identity_token          = identity_token.azurerm.jwt
    environment             = "prod"
    project_name            = "acme"
    location                = "westeurope"
    location_short          = "weu"
    address_space           = ["10.20.0.0/16"]
    workload_subnet_cidr    = "10.20.1.0/24"
    private_subnet_cidr     = "10.20.2.0/24"
    admin_ssh_public_key    = store.varset.stack_vars.stable.admin_ssh_public_key
    admin_cidrs             = []
    enable_public_ip        = false
    vm_size                 = "Standard_D2ps_v6"
    admin_username          = "azureuser"
    storage_container_name  = "appdata"
    ddos_protection_plan_id = null
    extra_tags = {
      environment = "prod"
    }
  }
}
