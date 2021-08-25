terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
    }
  }
}

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
    content      = file("${path.module}/pre-cloud-config.sh")
  }

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-config.cfg", {
      VLAN_ID_0  = var.metal_vlan_b[0].vxlan
      VLAN_ID_1  = var.metal_vlan_b[1].vxlan
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
resource "null_resource" "ssh-after-l2" {
  count      = var.backend_count
  depends_on = [metal_port.port]
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
resource "metal_port" "port" {
  count = var.backend_count

  port_id  = [for p in metal_device.backend[count.index].ports : p.id if p.name == "bond0"][0]
  layer2   = true
  bonded   = true
  vlan_ids = var.metal_vlan_b.*.id
}

