variable "project_id" {}
variable "backend_count" {}
variable "plan" {}
variable "operating_system" {}
variable "metro" {}
variable "metal_vlan_b" {}
variable "ssh_key" {}
variable "bastion_host" {}
variable "hardware_reservation_ids" {
  type    = list(string)
  default = []
}
