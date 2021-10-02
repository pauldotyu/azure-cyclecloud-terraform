output "cyclecloud_url" {
  value = "https://${azurerm_public_ip.cyclecloud.ip_address}"
}