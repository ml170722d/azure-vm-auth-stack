variable "name" {
  type = string
  description = "Resource group name"
}

variable "location" {
  type = string
  description = "Azure region"
}

variable "enable_delete_lock" {
  type = bool
  default = false
}
