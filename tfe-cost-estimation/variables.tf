variable "prefix" {
  default = "hashicorp-example"
}
variable "username" {
}
variable "password" {
}

variable "vm_size" {
  default = "Standard_B1s"
  # override with Standard_B20ms to test
}