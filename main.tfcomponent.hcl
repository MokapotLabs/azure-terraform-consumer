required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 4.20"
  }
  random = {
    source  = "hashicorp/random"
    version = "~> 3.7"
  }
}

stack "environment" {
  source  = "app.terraform.io/mbarcia/azure-terraform-example"
  version = "2.3.1"

  inputs = {
    client_id               = var.client_id
    tenant_id               = var.tenant_id
    subscription_id         = var.subscription_id
    identity_token          = var.identity_token
    environment             = var.environment
    project_name            = var.project_name
    location                = var.location
    location_short          = var.location_short
    address_space           = var.address_space
    workload_subnet_cidr    = var.workload_subnet_cidr
    private_subnet_cidr     = var.private_subnet_cidr
    admin_ssh_public_key    = var.admin_ssh_public_key
    admin_cidrs             = var.admin_cidrs
    enable_public_ip        = var.enable_public_ip
    vm_size                 = var.vm_size
    admin_username          = var.admin_username
    storage_container_name  = var.storage_container_name
    ddos_protection_plan_id = var.ddos_protection_plan_id
    extra_tags              = var.extra_tags
  }
}
