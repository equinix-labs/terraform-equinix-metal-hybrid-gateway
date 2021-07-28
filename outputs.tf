output "metrovlan_ids" {
   value = metal_vlan.metro_vlan[*].vxlan
}

output "frontend_name" {
  value        = module.frontend.frontend_name
  description  = "Your frondend node's hostname:"
}

output "frontend_IP" {
  value        = module.frontend.frontend_IP
  description  = "Your frondend node's IP:"
}

output "backend_nodes" {
  value        = module.backend.backend_nodes
  description  = "Your backend nodes:"
}
