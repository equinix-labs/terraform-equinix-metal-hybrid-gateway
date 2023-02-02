variable "auth_token" {
  type        = string
  description = "Your Equinix Metal API key (https://console.equinix.com/users/-/api-keys)"
  sensitive   = true
}

variable "hardware_reservation_ids" {
  type = object({
    frontend = optional(string, "")
    backends = optional(list(string), [])
  })
  default     = {}
  description = "Hardware Reservation ID for the Equinix Metal servers"

}

variable "project_id" {
  type        = string
  description = "Your Equinix Metal project ID, where you want to deploy your nodes to"
}

variable "plan" {
  type        = string
  description = "Metal server type you plan to deploy"
  default     = "c3.small.x86"
}

variable "operating_system" {
  type        = string
  description = "OS you want to deploy"
  default     = "ubuntu_20_04"
}

variable "metro" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = "da"
}

variable "backend_count" {
  type        = number
  description = "numbers of backend nodes you want to deploy"
  default     = 1
}

variable "vlan_count" {
  type        = number
  description = "Metal's Metro VLAN"
  default     = 2
}
