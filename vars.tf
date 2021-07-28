variable "auth_token" {
  type = string 
  description = "Your Packet API key in Personal Settings"
  default  = "your API token"
}

variable "project_id" {
  type = string
  description = "Your Metal project ID, where you want to deploy your nodes to"
  default = "your project ID"
}

variable "plan" {
  type = string
  description = "Metal server type you plan to deploy"
  default = "c3.small.x86"
}

variable "operating_system" {
  type = string
  description = "OS you want to deploy"
  default = "ubuntu_20_04"
}

variable "metro" {
  type = string
  description = "Metal's Metro location you want to deploy your servers to"
  default = "da"
}

variable "backend_count" {
  type = number
  description = "numbers of backend nodes you want to deploy"
  default = 1
}

variable "vlan_count" {
   type = number
   description = "Metal's Metro VLAN ID"
   default = 2
}
