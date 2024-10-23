#------------------------------------------------------------------------------
# Create USERS instances
#------------------------------------------------------------------------------
# Create user VM
module "user_fad" {
  source = "./sub_modules/fad"

  for_each = var.user_fad_ni_ids

  prefix  = "${var.prefix}-${each.key}"
  keypair = var.key_pair_name

  instance_type = var.instance_type

  ni_id       = each.value
  fad_ami_id  = var.fad_ami_id
  iam_profile = var.user_fad_iams[each.key]

  config_eip = false

  tags = var.tags
}