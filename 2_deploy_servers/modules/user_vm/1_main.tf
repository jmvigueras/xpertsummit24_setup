#------------------------------------------------------------------------------
# Create USERS instances
#------------------------------------------------------------------------------
# Create user VM
module "user_vm" {
  source = "./sub_modules/aws_new_vm_ni"

  for_each = var.user_vm_ni_ids

  prefix  = var.prefix
  suffix  = each.key
  keypair = var.key_pair_name

  instance_type = var.instance_type
  user_data     = data.template_file.user_vm_userdata[each.key].rendered

  ni_id = each.value

  tags = merge(
    var.tags,
    { Owner = each.key }
  )
}
# Create data template for master node
data "template_file" "user_vm_userdata" {
  for_each = var.user_vm_ni_ids

  template = file("${path.module}/templates/k8s_v2.sh")
  vars = {
    k8s_version    = var.k8s_version
    linux_user     = "ubuntu"
    k8s_deployment = data.template_file.k8s_app_deployment[each.key].rendered
    db_pass        = var.redis_db["pass"]
    script         = data.template_file.k8s_master_script[each.key].rendered
  }
}
# Create k8s manifest from template to deploy voting app
data "template_file" "k8s_app_deployment" {
  for_each = var.user_vm_ni_ids

  template = file("${path.module}/templates/k8s-dvwa-swagger.yaml")
  vars = {
    dvwa_nodeport    = var.app1_mapped_port
    swagger_nodeport = var.app2_mapped_port
    swagger_host     = var.user_fgt_eip_public[each.key]
    swagger_url      = "http://${var.user_xpert_urls[each.key]}:${var.app2_mapped_port}"
  }
}
data "template_file" "k8s_master_script" {
  template = file("${path.module}/templates/export-k8s-cluster-info.py")
  for_each = var.user_vm_ni_ids

  vars = {
    db_host         = var.redis_db["host"]
    db_port         = var.redis_db["port"]
    db_pass         = var.redis_db["pass"]
    master_ip       = var.user_fgt_eip_public[each.key]
    master_api_port = var.k8s_api_port
    prefix          = each.key
  }
}