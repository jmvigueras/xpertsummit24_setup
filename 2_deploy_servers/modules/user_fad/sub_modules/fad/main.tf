#-----------------------------------------------------------------------------------------------------
# fac
#-----------------------------------------------------------------------------------------------------
# Create Network interface
# Create EIP public NI
# - Creeat EIP associated to NI if config_eip is true
resource "aws_eip" "eip" {
  depends_on = [resource.aws_network_interface.ni]
  count      = var.config_eip ? 1 : 0

  domain            = "vpc"
  network_interface = local.ni_id

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-fad-eip-ni-${var.suffix}" }
  )
}
# Create NIs based on NI list
resource "aws_network_interface" "ni" {
  count = var.ni_id == null ? 1 : 0

  subnet_id       = var.subnet_id
  security_groups = var.security_groups

  private_ip_list_enabled = true
  private_ips             = local.private_ips

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-fad-ni-${var.suffix}" }
  )
}

# Create the instance FGT AZ1 Active
resource "aws_instance" "fad" {
  ami                  = local.fad_ami_id
  instance_type        = var.instance_type
  key_name             = var.keypair
  iam_instance_profile = var.iam_profile
  //user_data = data.template_file.fad_config.rendered

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = local.ni_id
  }

  tags = merge(
    var.tags,
    { Name = "${var.prefix}-fad-${var.suffix}" }
  )
}

data "template_file" "fad_config" {
  template = file("${path.module}/templates/fad.conf")
  vars = {
    id             = "${var.prefix}-fad"
    type           = var.license_type
    license_file   = var.license_file
    admin_username = var.admin_username
    rsa-public-key = var.rsa-public-key != null ? trimspace(var.rsa-public-key) : ""
    extra-config   = var.fad_extra_config
  }
}