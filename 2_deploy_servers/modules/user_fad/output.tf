# Output
output "user_fad" {
  value = { 
    for k, v in module.user_fad :
      k => merge(v.details, var.user_fad_ni_ips[k])
  }
}