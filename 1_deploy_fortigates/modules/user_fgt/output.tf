# Output
output "user_fgts" {
  value = { for k, v in module.user : k =>
    {
      fgt_mgmt    = "https://${v.fgt_eip_mgmt}:${var.admin_port}"
      fgt_public  = v.fgt_eip_public
      fgt_api_key = var.api_key
      username    = "admin"
      password    = v.fgt_id
      admin_cidr  = var.admin_cidr
      fgt_api_url = "https://${module.user_vpc[k].fgt_ni_ips["public"]}:${var.admin_port}"
    }
  }
}

output "user_fgt_eip_public" {
  value = { for k, v in module.user : k => v.fgt_eip_public }
}

output "user_xpert_ids" {
  value = { for k, v in module.user : k => local.spokes_sdwan[k]["xpert_id"] }
}

output "user_vm_ni_ids" {
  value = { for k, v in aws_network_interface.user_vm_ni : k => v.id }
}
output "user_vm_ni_ips" {
  value = { for k, v in local.spokes_sdwan : k => cidrhost(module.user_vpc[k]["subnet_az1_cidrs"]["bastion"], var.k8s_cidr_host) }
}

output "user_fad_ni_ids" {
  value = { for k, v in aws_network_interface.user_fad_ni : k => v.id }
}
output "user_fad_ni_ips" {
  value = {
    for k, v in local.spokes_sdwan :
    k => {
      "ip"     = cidrhost(module.user_vpc[k]["subnet_az1_cidrs"]["bastion"], var.fad_cidr_host),
      "ip_nat" = cidrhost(module.user_vpc[k]["subnet_az1_cidrs"]["bastion"], var.fad_cidr_host + 1)
    }
  }
}
output "user_fad_iam_profiles" {
  value = {
    for k, v in module.user : k => v.fgt_iam_profile
  }
}