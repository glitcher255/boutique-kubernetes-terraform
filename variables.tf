variable "location" {
  default = "eastus"
}

variable "rg_name" {
  default = "ASSIGNED_AUTOMATICALLY"
}
#RG_main_${var.location}_${var.environment}

variable "environment" {
  default = "dev1"
}

variable "terraform_workspace" {
  type        = string
  default     = "Terraform_Kubernetes_Boutique"
}