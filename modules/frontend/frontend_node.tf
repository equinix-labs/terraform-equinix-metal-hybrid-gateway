terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
    }
  }
}

variable "project_id" {}
variable "plan" {}
variable "operating_system" {}
variable "metro" {}
variable "vlan_count" {}
variable "metal_vlan_f" {}
variable "ssh_key" {}

output "metrovlan_id_f" {
  value = var.metal_vlan_f
}

## create the front-end node
resource "metal_device" "frontend" {
  hostname         = "front-end"
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
}

## execute script files in frontend node

resource "null_resource" "configure-network-frontend" {
  connection {
    host        = metal_device.frontend.access_public_ipv4
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_key
  }

  provisioner "file" {
    source      = "${path.module}/frontend.sh"
    destination = "/root/network-configurator.script"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/network-configurator.script",
      "/root/network-configurator.script ${var.metal_vlan_f}",
      "sudo systemctl restart networking"
    ]
    on_failure = continue
  }
  
 ## clean-up the network configuration file in frontend
  provisioner "remote-exec" {
    inline = [
        "rm -f /root/network-configurator.script"
    ]
  }
}

## To put the node in hybrid-bonded mode, leave the node in default L3 mode and attach a VLAN to bond0
resource "metal_port_vlan_attachment" "attach-vlan-frontend" {
  device_id  = metal_device.frontend.id
  port_name  = "bond0"
  force_bond = true
  vlan_vnid  = var.metal_vlan_f
  depends_on = [null_resource.configure-network-frontend]
}

## "frontend_name" and "frontend_IP" are used in main outputs file
output "frontend_name" {
  value       = metal_device.frontend.hostname
  description = "Your frondend node's hostname:"
}

output "frontend_IP" {
  value       = metal_device.frontend.access_public_ipv4
  description = "Your frondend node's IP:"
}
## -------------
