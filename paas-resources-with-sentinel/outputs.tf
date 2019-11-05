output "sql_server_fqdn" {
    value = "${azurerm_sql_server.example.fully_qualified_domain_name}"
}
