output "details" {
  description = "FortiADC details"
  value = {
    id             = aws_instance.fad.id
    username       = var.admin_username
    public_ip      = local.o_public_ip
  }
}

output "id" {
  description = "FortiADC instance ID"
  value       = aws_instance.fad.id
}

output "private_ips" {
  description = "FortiADC private IPs"
  value       = local.private_ips
}

output "public_ip" {
  description = "FortiADC public IP"
  value       = local.o_public_ip
}