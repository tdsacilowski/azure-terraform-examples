# Public IP Address of our VM
output "public_ip_address" {
  value = "${data.azurerm_public_ip.example.ip_address}"
}

output "foo" {
  value = "bar"
}
