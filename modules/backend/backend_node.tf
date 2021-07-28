terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
      version = ">= 2.1.0"
    }
  }
}

variable "project_id" {}
variable "backend_count" {}
variable "plan" {}
variable "operating_system" {}
variable "metro" {}
variable "vlan_count" {}
variable "metal_vlan_b" {}

# create backend nodes
resource "metal_device" "backend" {
  count            = var.backend_count
  hostname         = format("backend-%d", count.index + 1)
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
}

## execute  script file in backend nodes

resource "null_resource" "configure-network-backend" {
    count         =  var.backend_count
    connection {
      host        = metal_device.backend[count.index].access_public_ipv4
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_rsa")
    }

    provisioner "file" {
      source      = "${path.module}/backend.sh"
      destination = "/root/network-configurator.script"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /root/network-configurator.script",
        "/root/network-configurator.script ${var.metal_vlan_b[0]} ${var.metal_vlan_b[1]} ${count.index}",
        "sudo systemctl restart networking",
        "route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.168.100.1"
      ]
      on_failure = continue
    }
 
    ## clean-up the network configuration file 
    provisioner "remote-exec" {
      inline = [
        "rm -f /root/network-configurator.script"
      ]
    }  
}

## put backend nodes in layer2 bonded mode
resource "metal_device_network_type" "layer2" {
  count      = var.backend_count
  device_id  = metal_device.backend[count.index].id
  type       = "layer2-bonded"
  depends_on = [null_resource.configure-network-backend]
}

## attach vlans
resource "metal_port_vlan_attachment" "attach-vlan1-backend" {
  count      = var.backend_count
  device_id  = metal_device.backend[count.index].id
  port_name  = "bond0"
  vlan_vnid  = var.metal_vlan_b[0]
  depends_on = [metal_device_network_type.layer2]
}

resource "metal_port_vlan_attachment" "attach-vlan2-backend" {
  count     = var.backend_count
  device_id = metal_device.backend[count.index].id
  port_name = "bond0"
  vlan_vnid = var.metal_vlan_b[1]
  depends_on = [metal_device_network_type.layer2]
  #depends_on = [metal_port_vlan_attachment.attach-vlan1-backend]
}

## the "backend_nodes" is used in main outputs.tf files
output "backend_nodes" {
  value        = metal_device.backend.*.hostname
  description  = "Your backend nodes:"
}
## --------------------
