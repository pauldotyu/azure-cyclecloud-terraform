variable "location" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "vnet_address_space" {
  type = list(string)
}

variable "snet_address_space_cyclecloud" {
  type = list(string)
}

variable "snet_address_space_cluster" {
  type = list(string)
}

variable "vm_size" {
  type = string
}

variable "vm_managed_disk_type" {
  type = string
}

variable "vm_data_disk_size_gb" {
  type = number
}

variable "vm_admin_username" {
  type = string
}

variable "vm_image" {
  type = object({
    publisher     = string
    product_offer = string
    plan_sku      = string
    version       = string
  })
}