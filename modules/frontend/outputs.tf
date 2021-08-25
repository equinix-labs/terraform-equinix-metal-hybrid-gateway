output "metrovlan_id_f" {
  value = var.metal_vlan_f.vxlan
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
