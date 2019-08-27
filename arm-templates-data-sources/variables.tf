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