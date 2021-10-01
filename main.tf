provider "azurerm" {
  features {}
}

data "azurerm_subscription" "cc" {
}

resource "random_string" "cc" {
  length           = 4
  special          = false
  lower            = true
  override_special = "/@£$"
}

resource "azurerm_resource_group" "cc" {
  name     = "rg-cc-${random_string.cc.result}"
  location = "West US 2"
}

resource "azurerm_virtual_network" "cc" {
  name                = "vn-cc-${random_string.cc.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cc.location
  resource_group_name = azurerm_resource_group.cc.name
}

resource "azurerm_subnet" "cc" {
  name                 = "cyclecloud"
  resource_group_name  = azurerm_resource_group.cc.name
  virtual_network_name = azurerm_virtual_network.cc.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "cc_cluster" {
  name                 = "cluster"
  resource_group_name  = azurerm_resource_group.cc.name
  virtual_network_name = azurerm_virtual_network.cc.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "cc" {
  name                = "vmcc${random_string.cc.result}-pip"
  resource_group_name = azurerm_resource_group.cc.name
  location            = azurerm_resource_group.cc.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cc" {
  name                = "vmcc${random_string.cc.result}-nic"
  location            = azurerm_resource_group.cc.location
  resource_group_name = azurerm_resource_group.cc.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cc.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cc.id
  }
}

resource "azurerm_virtual_machine" "cc" {
  name                = "vmcc${random_string.cc.result}"
  location            = azurerm_resource_group.cc.location
  resource_group_name = azurerm_resource_group.cc.name
  vm_size             = "Standard_DS2_v2"

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.cc.id,
  ]

  storage_image_reference {
    publisher = "azurecyclecloud"
    offer     = "azure-cyclecloud"
    sku       = "cyclecloud8"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vmcc${random_string.cc.result}-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vmcc${random_string.cc.result}"
    admin_username = "cycleadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true


    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path = "/home/cycleadmin/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_managed_disk" "cc" {
  name                 = "vmcc${random_string.cc.result}-disk1"
  location             = azurerm_resource_group.cc.location
  resource_group_name  = azurerm_resource_group.cc.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "cc" {
  managed_disk_id    = azurerm_managed_disk.cc.id
  virtual_machine_id = azurerm_virtual_machine.cc.id
  lun                = "0"
  caching            = "ReadOnly"
}

resource "azurerm_storage_account" "cc" {
  name                     = "sacc${random_string.cc.result}"
  resource_group_name      = azurerm_resource_group.cc.name
  location                 = azurerm_resource_group.cc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "cc" {
  scope                = data.azurerm_subscription.cc.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_virtual_machine.cc.identity[0].principal_id
}