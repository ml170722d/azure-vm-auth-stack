variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Service Principal App (Client) ID"
}

variable "client_secret" {
  type        = string
  description = "Service Principal Client Secret"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "location" {
  type = string
  description = "Location of resources"
  default = "West Europe"
}

