terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
  }
}

provider "equinix" {
  auth_token = var.auth_token
}

module "example" {
  # Replace this path with the Git repo path or Terraform Registry path
  source = "../../"

  # Define any required variables
  hardware_reservation_ids = var.hardware_reservation_ids
  project_id               = var.project_id
  plan                     = var.plan
  operating_system         = var.operating_system
  metro                    = var.metro
  backend_count            = var.backend_count
  vlan_count               = var.vlan_count
}
