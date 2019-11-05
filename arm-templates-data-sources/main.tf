
#-------------------------------------------------------------------------------
# Configure our Provider
#-------------------------------------------------------------------------------
provider "azurerm" { }


#-------------------------------------------------------------------------------
# Create our Resource Group
#-------------------------------------------------------------------------------
resource "azurerm_resource_group" "example" {
  name     = "${var.environment_name}-azure-examples"
  location = "${var.location}"

  tags = {
    environment = "${var.environment_name}"
  }
}

#-------------------------------------------------------------------------------
# Create our VNet Using ARM Template Deployment
#-------------------------------------------------------------------------------
resource "azurerm_template_deployment" "example" {
  name                = "${var.environment_name}-vnet-template"
  resource_group_name = "${azurerm_resource_group.example.name}"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vnetName": {
      "type": "string",
      "defaultValue": "example-vnet",
      "metadata": {
        "description": "VNet name"
      }
    },
    "vnetAddressPrefix": {
      "type": "string",
      "defaultValue": "10.0.0.0/16",
      "metadata": {
        "description": "Address prefix"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources."
      }
    }
  },
  "variables": {},
  "resources": [
    {
      "apiVersion": "2018-10-01",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[parameters('vnetName')]",
      "location": "[parameters('location')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('vnetAddressPrefix')]"
          ]
        }
      }
    }
  ],
  "outputs": {
      "vnet-name": {
          "type": "string",
          "value": "[parameters('vnetName')]"
      }
  }
}
DEPLOY

  parameters = {
      "vnetName" = "${var.environment_name}-vnet"
  }

  deployment_mode = "Incremental"
}

#-------------------------------------------------------------------------------
# Use a Data Source to Query for the VNet Created by our ARM Template
#
# Hint: using outputs in the ARM template and referring to them in Terraform
# resources, as below, forces Terraform to wait for the ARM template
# deployment to finish before trying to reference the resources deployed by
# the ARM template
#-------------------------------------------------------------------------------
data "azurerm_virtual_network" "example" {
  name                = "${azurerm_template_deployment.example.outputs["vnet-name"]}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

#-------------------------------------------------------------------------------
# Create a Subnet in Which We'll Deploy Our VM
#-------------------------------------------------------------------------------
resource "azurerm_subnet" "example" {
  name                 = "${var.environment_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${data.azurerm_virtual_network.example.name}"
  address_prefix       = "10.0.0.0/24"
}

#-------------------------------------------------------------------------------
# Create a Public IP Address to Attach to our VM
#-------------------------------------------------------------------------------
resource "azurerm_public_ip" "example" {
    name                         = "${var.environment_name}-public-ip"
    location                     = "${azurerm_resource_group.example.location}"
    resource_group_name          = "${azurerm_resource_group.example.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.environment_name}"
    }
}

#-------------------------------------------------------------------------------
# Data Source to Query the Public IP
# 
# Note: we need to query this after the resource is created just due to how
# the address is created on the Azure side
#-------------------------------------------------------------------------------
data "azurerm_public_ip" "example" {
  name                = "${azurerm_public_ip.example.name}"
  resource_group_name = "${azurerm_virtual_machine.example.resource_group_name}"
}

#-------------------------------------------------------------------------------
# Create a NSG to Control Ingress Into Our VM
#-------------------------------------------------------------------------------
resource "azurerm_network_security_group" "example" {
    name                = "${var.environment_name}-security-group"
    location            = "${azurerm_resource_group.example.location}"
    resource_group_name = "${azurerm_resource_group.example.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        #source_address_prefix      = "*"
        source_address_prefix      = "${var.source_address_prefix}"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.environment_name}"
    }
}

#-------------------------------------------------------------------------------
# Create a Network Interface with Attached Public IP and Associated VM 
#-------------------------------------------------------------------------------
resource "azurerm_network_interface" "example" {
  name                      = "${var.environment_name}-nic"
  location                  = "${azurerm_resource_group.example.location}"
  resource_group_name       = "${azurerm_resource_group.example.name}"
  network_security_group_id = "${azurerm_network_security_group.example.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.example.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.example.id}"
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "${var.environment_name}-vm"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "${var.environment_name}"
  }
}


