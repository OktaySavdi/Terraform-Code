variable "region" {
  default = "northeurope"
}

variable "size" {
  type    = string
  default = "Standard_D2as_v5"
}

variable "environment" {
  default = "test"
}

variable "prefix" {
  default = "example"
}

variable "ssh_public_key" {
  default     = "C:\\setup\\putty\\oktay.key.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

variable "node_pool" {
  type = map(string)
  default = {
    "enable_auto_scaling"    = true
    "max_count"              = "3"
    "min_count"              = "1"
    "os_disk_size_gb"        = "30"
    "type"                   = "VirtualMachineScaleSets"
    "enable_node_public_ip"  = false
    "max_pods"               = "110"
    "enable_host_encryption" = false
  }
}

variable "node_pool" {
  type = map(string)
  default = {
    "nodepool-type" = "system"
    "environment"   = "dev"
    "nodepoolos"    = "linux"
    "app"           = "system-apps"
  }
}