## This TF file implements a front-end node (hybrid mode) and back-end node (in layer2 mode)
## both nodes are attached to one VLAN, backend node accesses internet via the front-end node
## to test, login to backend node via out-of-band and ping 8.8.8.8

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    equinix = {
      source  = "equinix/equinix"
      version = "~> 1.14"
    }
  }
  provider_meta "equinix" {
    module_name = "equinix-hybrid-gateway"
  }
}
provider "equinix" {
}

## allocate metro vlans for the project 
resource "equinix_metal_vlan" "metro_vlan" {
  count       = var.vlan_count
  description = "Metal's metro VLAN"
  metro       = var.metro
  project_id  = var.project_id
}

module "ssh" {
  source     = "./modules/ssh/"
  project_id = var.project_id
}

module "frontend" {
  source                  = "./modules/frontend/"
  project_id              = var.project_id
  plan                    = var.plan
  metro                   = var.metro
  operating_system        = var.operating_system
  metal_vlan_f            = { vxlan = equinix_metal_vlan.metro_vlan[0].vxlan, id = equinix_metal_vlan.metro_vlan[0].id }
  ssh_key                 = module.ssh.ssh_private_key_contents
  depends_on              = [equinix_metal_vlan.metro_vlan, module.ssh]
  hardware_reservation_id = try(var.hardware_reservation_ids.frontend, null)
}

module "backend" {
  source                  = "./modules/backend/"
  bastion_host            = module.frontend.frontend_IP
  backend_count           = var.backend_count
  project_id              = var.project_id
  plan                    = var.plan
  metro                   = var.metro
  operating_system        = var.operating_system
  metal_vlan_b            = [for v in equinix_metal_vlan.metro_vlan[*] : { vxlan = v.vxlan, id = v.id }]
  ssh_key                 = module.ssh.ssh_private_key_contents
  depends_on              = [equinix_metal_vlan.metro_vlan, module.ssh]
  hardware_reservation_ids = try(var.hardware_reservation_ids.backends, [])
}
