location = "westus2"
tags = {
  "po-number"          = "zzz"
  "environment"        = "prod"
  "mission"            = "administrative"
  "protection-level"   = "p1"
  "availability-level" = "a1"
  "repo"               = "pauldotyu/azure-cyclecloud-terraform"
}
vnet_address_space            = ["10.12.7.0/24"]
snet_address_space_cyclecloud = ["10.12.7.0/25"]
snet_address_space_cluster    = ["10.12.7.128/25"]
vm_admin_username             = "cycleadmin"
vm_size                       = "Standard_DS2_v2"
vm_managed_disk_type          = "Standard_LRS"
vm_data_disk_size_gb          = 128
vm_image = {
  publisher     = "azurecyclecloud"
  product_offer = "azure-cyclecloud"
  plan_sku      = "cyclecloud8"
  version       = "latest"
}
