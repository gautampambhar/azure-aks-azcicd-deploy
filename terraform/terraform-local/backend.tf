terraform {
  backend "azurerm" {
    resource_group_name   = "aks-tfstates-rg-lo"
    storage_account_name  = "akstfstatestrglo"
    container_name        = "tfstatefileslo"
    key                   = "dev.terraform.tfstate"
  }
}