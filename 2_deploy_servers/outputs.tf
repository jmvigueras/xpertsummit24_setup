# Generate aditional outputs
output "lab_server_details" {
  value = {
    lab_url        = "http://${local.server_fqdn}/${local.lab_token}"
    phpmyadmin_url = "http://${local.server_fqdn}/${local.random_url_db}"
  }
}

output "fortimail_details" {
  value = {
    mgmt_url  = "https://${local.mail_fqdn}/admin"
    users_url = "https://${local.mail_fqdn}"
    id        = module.fmail.id
  }
}

output "users_vm" {
  value = local.o_users_vm
}

output "users_fad" {
  value = local.o_users_fad
}

output "user_xpert_urls" {
  value = local.user_xpert_urls
}