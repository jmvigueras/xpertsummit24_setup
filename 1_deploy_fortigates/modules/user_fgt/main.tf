#------------------------------------------------------------------------------
# Create HUB AWS
# - VPC FGT hub
# - config FGT hub (FGCP)
# - FGT hub
# - Create test instances in bastion subnet
#------------------------------------------------------------------------------
// Create VPC for hub
module "user_vpc" {
  source = "./sub_modules/aws_fgt_vpc"

  for_each = local.spokes_sdwan

  prefix     = "${var.prefix}-${each.key}"
  admin_cidr = var.admin_cidr
  admin_port = var.admin_port
  region     = var.region

  vpc_cidr = each.value["cidr"]
}
// Create config for FGT hub (FGCP)
module "user_config" {
  source = "./sub_modules/aws_fgt_config"

  for_each = local.spokes_sdwan

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa-public-key = var.rsa_public_key
  api_key        = var.api_key

  subnet_cidrs = module.user_vpc[each.key].subnet_az1_cidrs
  fgt_ni_ips   = module.user_vpc[each.key].fgt_ni_ips

  license_type = var.license_type

  fgt_extra-config = join("\n",
    [data.template_file.user_extra_config_app1[each.key].rendered],
    [data.template_file.user_extra_config_app2[each.key].rendered],
    [data.template_file.user_extra_config_app1_fad[each.key].rendered],
    [data.template_file.user_extra_config_app2_fad[each.key].rendered],
    [data.template_file.user_extra_config_ssh_k8s[each.key].rendered],
    [data.template_file.user_extra_config_ssh_fad[each.key].rendered],
    [data.template_file.user_extra_config_hck_server[each.key].rendered]
  )

  config_spoke = true
  hubs         = var.vpn_hubs
  spoke        = each.value

  vpc-spoke_cidr = [each.value["cidr"]]
}
// Create FGT instances
module "user" {
  source = "./sub_modules/aws_fgt"

  for_each = local.spokes_sdwan

  prefix        = "${var.prefix}-${each.key}"
  region        = var.region
  instance_type = var.instance_type
  keypair       = var.key_pair_name

  license_type = var.license_type
  fgt_build    = var.fgt_build

  fgt_ni_ids = module.user_vpc[each.key].fgt_ni_ids
  fgt_config = module.user_config[each.key].fgt_config
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_app1" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.k8s_cidr_host)
    external_port = var.app1_external_port
    mapped_port   = var.app1_mapped_port
    public_port   = "port1"
    private_port  = "port2"
    suffix        = var.app1_external_port
  }
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_app2" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.k8s_cidr_host)
    external_port = var.app2_external_port
    mapped_port   = var.app2_mapped_port
    public_port   = "port1"
    private_port  = "port2"
    suffix        = var.app2_external_port
  }
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_app1_fad" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.fad_cidr_host)
    external_port = var.app1_external_port + 10
    mapped_port   = var.app1_mapped_port + 10
    public_port   = "port1"
    private_port  = "port2"
    suffix        = var.app1_external_port + 10
  }
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_app2_fad" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.fad_cidr_host)
    external_port = var.app2_external_port + 10
    mapped_port   = var.app2_mapped_port + 10
    public_port   = "port1"
    private_port  = "port2"
    suffix        = var.app2_external_port + 10
  }
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_ssh_k8s" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.k8s_cidr_host)
    external_port = "2222"
    mapped_port   = "22"
    public_port   = "port1"
    private_port  = "port2"
    suffix        = "2222"
  }
}
// Create data templates extra-config fgt
data "template_file" "user_extra_config_ssh_fad" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_vip.conf")
  vars = {
    external_ip   = module.user_vpc[each.key].fgt_ni_ips["public"]
    mapped_ip     = cidrhost(module.user_vpc[each.key].subnet_az1_cidrs["bastion"], var.fad_cidr_host)
    external_port = "8444"
    mapped_port   = "443"
    public_port   = "port1"
    private_port  = "port2"
    suffix        = "8444"
  }
}
// Create firewall policies to allow health check from Server
data "template_file" "user_extra_config_hck_server" {
  for_each = local.spokes_sdwan

  template = file("${path.module}/templates/fgt_config_student.conf")
  vars = {
    public_port   = "port1"
    private_port  = "port2"
    lab_server_ip = var.lab_srv_private_ip
    tag_student   = "please-use-student-id"
  }
}
// Create NIC for Users VM
resource "aws_network_interface" "user_vm_ni" {
  for_each = local.spokes_sdwan

  subnet_id         = module.user_vpc[each.key].subnet_az1_ids["bastion"]
  security_groups   = [module.user_vpc[each.key].nsg_ids["bastion"]]
  private_ips       = [cidrhost(module.user_vpc[each.key]["subnet_az1_cidrs"]["bastion"], var.k8s_cidr_host)]
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-${each.key}"
  }
}
// Create NIC for Users FAD
resource "aws_network_interface" "user_fad_ni" {
  for_each = local.spokes_sdwan

  subnet_id       = module.user_vpc[each.key].subnet_az1_ids["bastion"]
  security_groups = [module.user_vpc[each.key].nsg_ids["bastion"]]

  private_ip_list_enabled = true
  private_ip_list = [
    cidrhost(module.user_vpc[each.key]["subnet_az1_cidrs"]["bastion"], var.fad_cidr_host),
    cidrhost(module.user_vpc[each.key]["subnet_az1_cidrs"]["bastion"], var.fad_cidr_host + 1)
  ]

  source_dest_check = false
  tags = {
    Name = "${var.prefix}-${each.key}"
  }
}