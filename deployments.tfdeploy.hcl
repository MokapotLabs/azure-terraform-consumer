identity_token "azurerm" {
  audience = ["api://AzureADTokenExchange"]
}

deployment "dev" {
  inputs = {
    client_id               = var.dev_client_id
    tenant_id               = var.dev_tenant_id
    subscription_id         = var.dev_subscription_id
    identity_token          = identity_token.azurerm.jwt
    environment             = "dev"
    project_name            = var.project_name
    location                = "eastus"
    location_short          = "eus"
    address_space           = ["10.10.0.0/16"]
    workload_subnet_cidr    = "10.10.1.0/24"
    private_subnet_cidr     = "10.10.2.0/24"
    admin_ssh_public_key    = var.admin_ssh_public_key
    admin_cidrs             = ["203.0.113.10/32"]
    enable_public_ip        = true
    vm_size                 = var.vm_size
    admin_username          = var.admin_username
    storage_container_name  = var.storage_container_name
    ddos_protection_plan_id = var.ddos_protection_plan_id
    extra_tags = merge(var.extra_tags, {
      environment = "dev"
    })
  }
}

deployment "prod" {
  inputs = {
    client_id               = var.prod_client_id
    tenant_id               = var.prod_tenant_id
    subscription_id         = var.prod_subscription_id
    identity_token          = identity_token.azurerm.jwt
    environment             = "prod"
    project_name            = var.project_name
    location                = "westeurope"
    location_short          = "weu"
    address_space           = ["10.20.0.0/16"]
    workload_subnet_cidr    = "10.20.1.0/24"
    private_subnet_cidr     = "10.20.2.0/24"
    admin_ssh_public_key    = var.admin_ssh_public_key
    admin_cidrs             = []
    enable_public_ip        = false
    vm_size                 = var.vm_size
    admin_username          = var.admin_username
    storage_container_name  = var.storage_container_name
    ddos_protection_plan_id = var.ddos_protection_plan_id
    extra_tags = merge(var.extra_tags, {
      environment = "prod"
    })
  }
}
