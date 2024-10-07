#-----------------------------------------------------------------------------------------------------
# fac
#-----------------------------------------------------------------------------------------------------
# Create Network interface
# Create EIP public NI
# - Creeat EIP associated to NI if config_eip is true
resource "aws_eip" "eip" {
  count = var.config_eip ? 1 : 0

  domain            = "vpc"
  network_interface = local.ni_id

  tags = merge(
    { Name = "${var.prefix}-vm-eip-ni-${var.suffix}" },
    var.tags
  )
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "fmail" {
  ami           = var.license_type == "byol" ? data.aws_ami_ids.fmail_amis_byol.ids[0] : data.aws_ami_ids.fmail_amis_payg.ids[0]
  instance_type = var.instance_type
  key_name      = var.keypair
  //iam_instance_profile = null
  //user_data = data.template_file.fmail_config.rendered

  /*
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  */
  root_block_device {
    encrypted = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = local.ni_id
  }

  tags = merge(
    { Name = "${var.prefix}-fmail" },
    var.tags
  )
}

data "template_file" "fmail_config" {
  template = file("${path.module}/templates/user-data.conf")
  vars = {
    id             = "${var.prefix}-fmail"
    type           = var.license_type
    license_file   = var.license_file
    admin_username = var.admin_username
    rsa-public-key = var.rsa-public-key != null ? trimspace(var.rsa-public-key) : ""
    extra-config   = var.fmail_extra_config
  }
}