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
  source = "../../"

  metro                    = var.metro
  project_id               = var.project_id
  backend_count            = var.backend_count
  hardware_reservation_ids = var.hardware_reservation_ids
}
