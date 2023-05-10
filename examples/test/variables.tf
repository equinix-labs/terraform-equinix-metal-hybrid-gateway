variable "auth_token" {
  type        = string
  description = "Your Equinix Metal API key (https://console.equinix.com/users/-/api-keys)"
  sensitive   = true
}

variable "project_id" {
  type    = string
  default = "Equinix Metal Project ID"
}

variable "metro" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = "da"
}

variable "backend_count" {
  type    = number
  default = 1
}

variable "hardware_reservation_ids" {
  type = object({
    frontend = optional(string, "")
    backends = optional(list(string), [])
  })
  default     = {}
  description = "Hardware Reservation ID for the Equinix Metal servers"
}
