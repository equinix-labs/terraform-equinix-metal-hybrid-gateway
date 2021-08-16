terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
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
variable "ssh_key" {}
variable "bastion_host" {}

# create backend nodes
resource "metal_device" "backend" {
  count            = var.backend_count
  hostname         = format("backend-%d", count.index + 1)
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id

  user_data = data.cloudinit_config.config[count.index].rendered
}

data "cloudinit_config" "config" {
  count         = var.backend_count
  gzip          = false # not supported on Equinix Metal
  base64_encode = false # not supported on Equinix Metal

  part {
    content_type = "text/x-shellscript"
    content = file("${path.module}/pre-cloud-config.sh")
  }

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-config.cfg", {
      VLAN_ID_0  = var.metal_vlan_b[0]
      VLAN_ID_1  = var.metal_vlan_b[1]
      LAST_DIGIT = count.index + 2
    })
  }

  part {
    filename     = "network-config"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/network-config.cfg", {
      VLAN_ID_0  = var.metal_vlan_b[0]
      VLAN_ID_1  = var.metal_vlan_b[1]
      LAST_DIGIT = count.index + 2
    })
  }

  ## Additional scripts can be run at boot
  # part {
  #   content_type = "text/x-shellscript"
  #   content = file("${path.module}/more_boot.sh")
  # }
}

## Example for executing scripts on backend nodes
## Note: The frontend node is used as a bastion_host because the backend nodes do not have public addresses.
resource "null_resource" "configure-network-backend" {
  count = var.backend_count
  connection {
    host        = metal_device.backend[count.index].access_public_ipv4
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_key

    bastion_host = var.bastion_host
  }

  ## Additional scripts can be run over SSH
  # provisioner "remote-exec" {
  #  scripts = ["${path.module}/more_ssh.sh"]
  # }
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
  count      = var.backend_count
  device_id  = metal_device.backend[count.index].id
  port_name  = "bond0"
  vlan_vnid  = var.metal_vlan_b[1]
  depends_on = [metal_device_network_type.layer2]
  #depends_on = [metal_port_vlan_attachment.attach-vlan1-backend]
}

## the "backend_nodes" is used in main outputs.tf files
output "backend_nodes" {
  value       = metal_device.backend.*.hostname
  description = "Your backend nodes:"
}
## --------------------
