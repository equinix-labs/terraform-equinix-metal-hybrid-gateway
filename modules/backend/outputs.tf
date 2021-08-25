## the "backend_nodes" is used in main outputs.tf files
output "backend_nodes" {
  value       = metal_device.backend.*.hostname
  description = "Your backend nodes:"
}
