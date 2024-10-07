# Locals for generate resources
locals {
  private_ip_list = try([for i in range(0, var.num_private_ips) : cidrhost(var.subnet_cidr, var.cidr_host + i)], [])
  private_ips     = try(var.private_ips, local.private_ip_list,[])

  ni_id = try(var.ni_id, one(aws_network_interface.ni.*.id))

  fad_ami_id = var.fad_ami_id != null ? var.fad_ami_id : var.license_type == "byol" ? data.aws_ami_ids.fad_amis_byol.ids[0] : data.aws_ami_ids.fad_amis_payg.ids[0]

  # Outputs
  o_public_ip = var.config_eip ? one(aws_eip.eip.*.public_ip) : ""
}

# Get current region
data "aws_region" "current" {}

# Get the last AMI Images from AWS MarektPlace FGT PAYG
data "aws_ami_ids" "fad_amis_payg" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FADC-AWS-PAYG-${var.fad_btw}-${var.fad_version}*"]
  }
}
data "aws_ami_ids" "fad_amis_byol" {
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FADC-AWS-BYOL-${var.fad_version}*"]
  }
}