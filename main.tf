provider "azurerm" {
  features {}
}

data "azurerm_subscription" "cyclecloud" {
}

resource "null_resource" "cyclecloud" {
  provisioner "local-exec" {
    #command = "az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8:latest"
    command = "az vm image terms accept --urn ${var.vm_image.publisher}:${var.vm_image.product_offer}:${var.vm_image.plan_sku}:${var.vm_image.version}"
  }
}

resource "random_pet" "cyclecloud" {
  length    = 2
  separator = ""
}

resource "azurerm_resource_group" "cyclecloud" {
  name     = "rg-${random_pet.cyclecloud.id}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "cyclecloud" {
  name                = "vn-${random_pet.cyclecloud.id}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.cyclecloud.location
  resource_group_name = azurerm_resource_group.cyclecloud.name
  tags                = var.tags
}

resource "azurerm_subnet" "cyclecloud" {
  name                 = "cyclecloud"
  resource_group_name  = azurerm_resource_group.cyclecloud.name
  virtual_network_name = azurerm_virtual_network.cyclecloud.name
  address_prefixes     = var.snet_address_space_cyclecloud
}

resource "azurerm_subnet" "cyclecloud_cluster" {
  name                 = "cluster"
  resource_group_name  = azurerm_resource_group.cyclecloud.name
  virtual_network_name = azurerm_virtual_network.cyclecloud.name
  address_prefixes     = var.snet_address_space_cluster
}

resource "azurerm_public_ip" "cyclecloud" {
  name                = "vm${random_pet.cyclecloud.id}-pip"
  resource_group_name = azurerm_resource_group.cyclecloud.name
  location            = azurerm_resource_group.cyclecloud.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_network_interface" "cyclecloud" {
  name                = "vm${random_pet.cyclecloud.id}-nic"
  location            = azurerm_resource_group.cyclecloud.location
  resource_group_name = azurerm_resource_group.cyclecloud.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.cyclecloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cyclecloud.id
  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "cyclecloud" {
  name                = "vm${random_pet.cyclecloud.id}"
  location            = azurerm_resource_group.cyclecloud.location
  resource_group_name = azurerm_resource_group.cyclecloud.name
  vm_size             = var.vm_size

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.cyclecloud.id,
  ]

  plan {
    name      = var.vm_image.plan_sku
    publisher = var.vm_image.publisher
    product   = var.vm_image.product_offer
  }

  storage_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.product_offer
    sku       = var.vm_image.plan_sku
    version   = var.vm_image.version
  }

  storage_os_disk {
    name              = "vm${random_pet.cyclecloud.id}-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.vm_managed_disk_type
  }

  os_profile {
    computer_name  = "vm${random_pet.cyclecloud.id}"
    admin_username = var.vm_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
    }
  }

  tags = var.tags

  depends_on = [
    null_resource.cyclecloud
  ]
}

resource "azurerm_managed_disk" "cyclecloud" {
  name                 = "vm${random_pet.cyclecloud.id}-DataDisk1"
  location             = azurerm_resource_group.cyclecloud.location
  resource_group_name  = azurerm_resource_group.cyclecloud.name
  storage_account_type = var.vm_managed_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_data_disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "cyclecloud" {
  managed_disk_id    = azurerm_managed_disk.cyclecloud.id
  virtual_machine_id = azurerm_virtual_machine.cyclecloud.id
  lun                = "1"
  caching            = "ReadOnly"
}

resource "azurerm_storage_account" "cyclecloud" {
  name                     = "sa${random_pet.cyclecloud.id}"
  resource_group_name      = azurerm_resource_group.cyclecloud.name
  location                 = azurerm_resource_group.cyclecloud.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_role_assignment" "cyclecloud" {
  scope                = data.azurerm_subscription.cyclecloud.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_virtual_machine.cyclecloud.identity[0].principal_id
}