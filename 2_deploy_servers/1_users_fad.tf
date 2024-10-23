# Create users VM in Region 1
module "r1_users_fad" {
  source = "./modules/user_fad"

  region        = local.r1_region
  key_pair_name = local.keypair_names["r1"]
  prefix        = local.prefix
  instance_type = local.fad_instance_type

  fad_ami_id      = local.fad_ami_ids["r1"]
  user_fad_ni_ids = local.user_fad_ni_ids["r1"]
  user_fad_ni_ips = local.user_fad_ni_ips["r1"]
  user_fad_iams   = local.user_fad_iam_profiles["r1"]

  access_key = var.access_key
  secret_key = var.secret_key

  tags = { "Project" = local.prefix }
}
# Create users VM in Region 2
module "r2_users_fad" {
  source = "./modules/user_fad"

  region        = local.r2_region
  key_pair_name = local.keypair_names["r2"]
  prefix        = local.prefix
  instance_type = local.fad_instance_type

  fad_ami_id      = local.fad_ami_ids["r2"]
  user_fad_ni_ids = local.user_fad_ni_ids["r2"]
  user_fad_ni_ips = local.user_fad_ni_ips["r2"]
  user_fad_iams   = local.user_fad_iam_profiles["r2"]

  access_key = var.access_key
  secret_key = var.secret_key

  tags = { "Project" = local.prefix }
}
# Create users VM in Region 3
module "r3_users_fad" {
  source = "./modules/user_fad"

  region        = local.r3_region
  key_pair_name = local.keypair_names["r3"]
  prefix        = local.prefix
  instance_type = local.fad_instance_type

  fad_ami_id      = local.fad_ami_ids["r3"]
  user_fad_ni_ids = local.user_fad_ni_ids["r3"]
  user_fad_ni_ips = local.user_fad_ni_ips["r3"]
  user_fad_iams   = local.user_fad_iam_profiles["r3"]

  access_key = var.access_key
  secret_key = var.secret_key

  tags = { "Project" = local.prefix }
}

