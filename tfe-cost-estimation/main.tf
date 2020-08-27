provider "azurerm" {
  features {}
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "${var.username}"
    admin_password = "${var.password}"

    custom_data = "echo 'init test'"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
    owner = "${var.username}"
    organization = "hashicorp"
    application = "example"
  }
}
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West US"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_virtual_machine_scale_set" "prod-web-servers" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  upgrade_policy_mode   = "Automatic"

  sku {
    name     = "${var.vm_size}"
    tier     = "Standard"
    capacity = 0
  }
  network_profile {
    name    = "WebNetworkProfile"
    primary = true
    ip_configuration {
      name      = "${var.prefix}-nic"
      primary   = true
      subnet_id = "${azurerm_subnet.internal.id}"
    }
  }
  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name_prefix = "${var.prefix}-vm-"
    admin_username = "${var.username}"
    admin_password = "${var.password}"

    custom_data = "echo 'init test'"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
    owner = "ggillen"
    organization = "hashicorp"
    application = "example"
  }
}
