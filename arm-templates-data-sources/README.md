# Example Using ARM Templates and Terraform Data Sources

This example will show the following:
- Using Terraform to create an Azure Resource Group
- Using the [`azurerm_template_deployment`][1] resource to create a Virtual Network using an ARM template (please review notes/caveats for this resource on the documentation page) 
- Using a Terraform Data Source to query for the VNet created by our ARM template and create a Subnet in that VNet
- Using Terraform to create a VM in the appropriate VNet and Subnet
- Using Terraform to create appropriate firewall rules for the VM

[1]: https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html