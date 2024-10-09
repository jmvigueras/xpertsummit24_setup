#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "xps24"

  r1_region = {
    id  = "eu-west-1"
    az1 = "eu-west-1a"
    az2 = "eu-west-1c"
  }
  r2_region = {
    id  = "eu-west-2"
    az1 = "eu-west-2a"
    az2 = "eu-west-2c"
  }
  r3_region = {
    id  = "eu-west-3"
    az1 = "eu-west-3a"
    az2 = "eu-west-3c"
  }
  hub_region = {
    id  = "eu-central-1"
    az1 = "eu-central-1a"
    az2 = "eu-central-1c"
  }
  #-----------------------------------------------------------------------------------------------------
  # APP details 
  #-----------------------------------------------------------------------------------------------------
  k8s_instance_type = "t3.xlarge"

  app1_mapped_port = "31000"
  app2_mapped_port = "31001"

  #--------------------------------------------------------------------------------------------
  # Server LAB variables
  #--------------------------------------------------------------------------------------------
  # LAB servers FQDNs
  dns_domain  = "fortidemoscloud.com"
  dns_zone_id = "Z0204711R1XYLX8XRXCS"
  lab_fqdn    = "www.${local.dns_domain}"
  server_fqdn = "server.${local.dns_domain}"
  mail_fqdn   = "mail.${local.dns_domain}"

  lab_token = trimspace(random_string.lab_token.result)

  # Instance type 
  lab_srv_type = "t3.2xlarge"

  # Git repository
  git_uri          = "https://github.com/jmvigueras/xpertsummit24_setup.git"
  git_uri_app_path = "/xpertsummit24_setup/0_modules/hub-server/"

  # DB
  random_url_db = trimspace(random_string.db_url.result)

  mysql_db = {
    host  = "mysqldb"
    user  = "root"
    pass  = local.random_url_db
    name  = "students"
    table = "students"
    port  = "3306"
  }

  redis_db = {
    host = local.server_fqdn // Fortigates HUB1 FQDN
    port = "63799"           // external port where fortigates HUB1 VIPs are listening
    pass = local.random_url_db
  }

  #-----------------------------------------------------------------------------------------------------
  # FMAIL details 
  #-----------------------------------------------------------------------------------------------------
  fmail_license_type = "payg"
  fmail_version      = "7.4.2"

  #-----------------------------------------------------------------------------------------------------
  # FortiADC details 
  #-----------------------------------------------------------------------------------------------------
  fad_ami_ids = {
    r1 = "ami-0b914657b7a27d6ce"
    r2 = "ami-0cdd29a93dee4cf08"
    r3 = "ami-07af3d754594b728c"
  }
  fad_instance_type = "m5.large"

  #-----------------------------------------------------------------------------------------------------
  # Other deployments variables 
  #-----------------------------------------------------------------------------------------------------
  keypair_names         = data.terraform_remote_state.deploy_fortigates.outputs.keypair_names
  user_vm_ni_ids        = data.terraform_remote_state.deploy_fortigates.outputs.user_vm_ni_ids
  user_fad_ni_ids       = data.terraform_remote_state.deploy_fortigates.outputs.user_fad_ni_ids
  user_fad_ni_ips       = data.terraform_remote_state.deploy_fortigates.outputs.user_fad_ni_ips
  user_fad_iam_profiles = data.terraform_remote_state.deploy_fortigates.outputs.user_fad_iam_profiles
  user_fgt_eip_public   = data.terraform_remote_state.deploy_fortigates.outputs.user_fgt_eip_public
  hub_lab_server_ni     = data.terraform_remote_state.deploy_fortigates.outputs.lab_server_ni
  hub_fmail_ni          = data.terraform_remote_state.deploy_fortigates.outputs.fmail_ni

  #-----------------------------------------------------------------------------------------------------
  # Outputs 
  #-----------------------------------------------------------------------------------------------------
  o_users_vm  = merge(module.r1_users_vm.user_vm, module.r2_users_vm.user_vm, module.r3_users_vm.user_vm)
  o_users_fad = merge(module.r1_users_fad.user_fad, module.r2_users_fad.user_fad, module.r3_users_fad.user_fad)
}

# Get state file from day0 deployment
data "terraform_remote_state" "deploy_fortigates" {
  backend = "local"
  config = {
    path = "../2_deploy_fortigates/terraform.tfstate"
  }
}
# Create random string for DB phpmyadmin url name
resource "random_string" "db_url" {
  length  = 10
  special = false
  numeric = false
}
# Create random string for access LAB
resource "random_string" "lab_token" {
  length  = 30
  special = false
  numeric = false
}