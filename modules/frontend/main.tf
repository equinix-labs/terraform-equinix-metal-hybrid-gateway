terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
    }
  }
}

## create the front-end node
resource "metal_device" "frontend" {
  hostname         = "front-end"
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = data.cloudinit_config.config.rendered
}

data "cloudinit_config" "config" {
  gzip          = false # not supported on Equinix Metal
  base64_encode = false # not supported on Equinix Metal

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-config.cfg", {
      VLAN_ID_0 = var.metal_vlan_f.vxlan
    })
  }
}

resource "metal_port" "attach-vlan-frontend" {
  port_id  = [for p in metal_device.frontend.ports : p.id if p.name == "bond0"][0]
  layer2   = false
  bonded   = true
  vlan_ids = [var.metal_vlan_f.id]
}

