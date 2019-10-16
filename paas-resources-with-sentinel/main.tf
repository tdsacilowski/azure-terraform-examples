#-------------------------------------------------------------------------------
# Configure our provider
#-------------------------------------------------------------------------------
provider "azurerm" { }

#-------------------------------------------------------------------------------
# Query our current client
#-------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}


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
# Create a simple SQL Server
#-------------------------------------------------------------------------------
resource "azurerm_sql_server" "example" {
  name                         = "${var.environment_name}-sql-server"
  resource_group_name          = "${azurerm_resource_group.example.name}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${var.administrator_login_password}"

  tags = {
    environment = "${var.environment_name}"
  }
}

#-------------------------------------------------------------------------------
# Set an AD Admin for our Azure SQL Server
#-------------------------------------------------------------------------------
resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = "${azurerm_sql_server.example.name}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  login               = "${var.ad_administrator_login}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${data.azurerm_client_config.current.object_id}"
}

#-------------------------------------------------------------------------------
# Create an Azure SQL Firewall Rule
#-------------------------------------------------------------------------------
resource "azurerm_sql_firewall_rule" "example" {
  name                = "${var.environment_name}-sql-firewall-rule"
  resource_group_name = "${azurerm_resource_group.example.name}"
  server_name         = "${azurerm_sql_server.example.name}"
  start_ip_address    = "${var.sql_firewall_rule_start_ip_address}"
  end_ip_address      = "${var.sql_firewall_rule_end_ip_address}"
}
