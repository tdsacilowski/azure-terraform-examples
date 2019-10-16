variable environment_name {
    description = "Unique identifier to apply to each resource name and environment tag"
    default     = "example"
}

variable location {
    description = "Name of region to deploy resouces into"
    default     = "East US"
}

variable source_address_prefix {
    description = "CIDR or * for testing SG Sentinel policy"
    default     = "*"
}

variable administrator_login {
    description = "Administrative user to create for login"
}

variable administrator_login_password {
    description = "Password for administrative login user"
}

variable ad_administrator_login {
    description = "Administrative user to create for login"
}

variable "sql_firewall_rule_start_ip_address" {
    description = "Azure SQL Firewall rule"
}

variable "sql_firewall_rule_end_ip_address" {
    description = "Azure SQL Firewall rule"
}
