## This TF file implements a front-end node (hybrid mode) and back-end node (in layer2 mode)
## both nodes are attached to one VLAN, backend node accesses internet via the front-end node
## to test, login to backend node via out-of-band and ping 8.8.8.8

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    metal = {
      source  = "equinix/metal"
      version = ">= 3.0"
    }
  }
}
provider "metal" {
  auth_token = var.auth_token
}

## allocate metro vlans for the project 
resource "metal_vlan" "metro_vlan" {
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
  source           = "./modules/frontend/"
  project_id       = var.project_id
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  vlan_count       = var.vlan_count
  metal_vlan_f     = metal_vlan.metro_vlan[0].vxlan
  ssh_key          = module.ssh.ssh_private_key_contents
  depends_on       = [metal_vlan.metro_vlan]
}

module "backend" {
  source           = "./modules/backend/"
  bastion_host     = module.frontend.frontend_IP
  backend_count    = var.backend_count
  project_id       = var.project_id
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  vlan_count       = var.vlan_count
  metal_vlan_b     = metal_vlan.metro_vlan[*].vxlan
  ssh_key          = module.ssh.ssh_private_key_contents
  depends_on       = [metal_vlan.metro_vlan]
}
