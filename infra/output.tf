output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "github_identity_client_id" {
  value = azurerm_user_assigned_identity.github_identity.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

