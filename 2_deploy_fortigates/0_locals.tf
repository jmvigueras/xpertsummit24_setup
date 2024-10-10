#-----------------------------------------------------------------------------------------------------
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment
#-----------------------------------------------------------------------------------------------------
locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "xps24"

  # Number of users peer region
  number_users = 1

  # Regions to deploy
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
  # FGT details 
  #-----------------------------------------------------------------------------------------------------
  admin_port        = "8443"
  admin_cidr        = "0.0.0.0/0"
  fgt_instance_type = "c6in.large"
  fgt_build_745     = "build2702"
  fgt_build_760     = "build3401"
  license_type      = "payg"

  #-----------------------------------------------------------------------------------------------------
  # APP details 
  #-----------------------------------------------------------------------------------------------------
  app1_external_port = 31000
  app2_external_port = 31001
  app1_mapped_port   = 31000
  app2_mapped_port   = 31001

  redis_external_port = "63799"
  redis_mapped_port   = "6379"

  lab_server_external_port = "80"
  lab_server_mapped_port   = "80"

  k8s_cidr_host = 10
  fad_cidr_host = 7

  #-----------------------------------------------------------------------------------------------------
  # HUBs variables
  #-----------------------------------------------------------------------------------------------------
  # Lab DNS zone
  config_dns_records = true // set to false if you don't have a AWS route53 zone
  route53_zone_name  = "fortidemoscloud.com"

  hub_1_vpc_cidr = "10.1.0.0/24"
  hub_2_vpc_cidr = "10.2.0.0/24"

  hub_1_spoke_to_tgw_cidrs = ["10.1.100.0/24"] // VPC spoke attached to TGW (at least one)

  hub_1_dns_record = "hub1"
  hub_2_dns_record = "hub2"

  hub_1_id            = "EMEA"
  hub_1_bgp_asn_hub   = "65001"
  hub_1_bgp_asn_spoke = "65000"
  hub_1_vpn_cidr      = "172.16.100.0/24" // VPN DialUp spokes cidr
  hub_1_cidr          = "10.0.0.0/8"      // AWS prefix 

  hub_2_id            = "EMEA"
  hub_2_bgp_asn_hub   = "65000"           // iBGP RR server
  hub_2_bgp_asn_spoke = "65000"           // iBGP RR client
  hub_2_vpn_cidr      = "172.16.200.0/24" // VPN DialUp spokes cidr
  hub_2_cidr          = "10.0.0.0/8"      // AWS prefix 

  # Config VPN DialUps FGT HUB
  hub_1 = [
    {
      id            = local.hub_1_id
      bgp_asn_hub   = local.hub_1_bgp_asn_hub
      bgp_asn_spoke = local.hub_1_bgp_asn_spoke
      vpn_cidr      = local.hub_1_vpn_cidr
      vpn_psk       = trimspace(random_string.vpn_psk.result)
      cidr          = local.hub_1_cidr
    }
  ]

  hub_2 = [
    {
      id            = local.hub_2_id
      bgp_asn_hub   = local.hub_2_bgp_asn_hub
      bgp_asn_spoke = local.hub_2_bgp_asn_spoke
      vpn_cidr      = local.hub_2_vpn_cidr
      vpn_psk       = trimspace(random_string.vpn_psk.result)
      cidr          = local.hub_2_cidr
    }
  ]

  #vpn_hubs = module.dual_hub.hubs
  # Create an error SDWAN VPN variable for troubleshooting
  vpn_hubs = [for i, v in module.dual_hub.hubs : merge(v, { external_fqdn = "error-hub${i + 1}.${local.route53_zone_name}" })]

  #-----------------------------------------------------------------------------------------------------
  # Outputs
  #-----------------------------------------------------------------------------------------------------
  r1_users_fgt = { for k, v in module.r1_users_fgt.user_fgts : k => v }
  r2_users_fgt = { for k, v in module.r2_users_fgt.user_fgts : k => v }
  r3_users_fgt = { for k, v in module.r3_users_fgt.user_fgts : k => v }

  users_fgt = merge(local.r1_users_fgt, local.r2_users_fgt, local.r3_users_fgt)
}
