output "drain" {
  value       = local.drain
  description = "The IAM role details for a default drain role."
}

output "execution" {
  value       = local.execution
  description = "The IAM role details for a default execution role."
}

output "scheduler" {
  value       = local.scheduler
  description = "The IAM role details for a default scheduler role."
}

output "server" {
  value       = local.server
  description = "The IAM role details for a default server role."
}

output "vcs_gateway" {
  value       = local.vcs_gateway
  description = "The IAM role details for a default VCS gateway role."
}
