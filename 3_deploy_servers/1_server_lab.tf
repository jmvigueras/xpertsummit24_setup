#--------------------------------------------------------------------------------------------
# Create LAB Server
#--------------------------------------------------------------------------------------------
# Create master node LAB server
module "lab_server" {
  source = "./modules/lab_vm"

  region        = local.hub_region
  prefix        = "${local.prefix}-lab-server"
  keypair       = local.keypair_names["hub"]
  instance_type = local.lab_srv_type
  linux_os      = "amazon"
  user_data     = data.template_file.srv_user_data.rendered
  iam_profile   = aws_iam_instance_profile.lab-portal-apicall-profile.name

  ni_id = local.hub_lab_server_ni

  access_key = var.access_key
  secret_key = var.secret_key
}
# Create user-data for server
data "template_file" "srv_user_data" {
  template = file("./templates/server_user-data.tpl")
  vars = {
    git_uri          = local.git_uri
    git_uri_app_path = local.git_uri_app_path
    docker_file      = data.template_file.srv_user_data_dockerfile.rendered
    nginx_config     = data.template_file.srv_user_data_nginx_config.rendered
    nginx_html       = data.template_file.srv_user_data_nginx_html.rendered

    redis_pass = local.redis_db["pass"]
  }
}
// Create dockerfile
data "template_file" "srv_user_data_dockerfile" {
  template = file("./templates/docker-compose.yaml")
  vars = {
    lab_fqdn      = local.lab_fqdn
    random_url_db = local.random_url_db
    db_host       = local.mysql_db["host"]
    db_user       = local.mysql_db["user"]
    db_pass       = local.mysql_db["pass"]
    db_name       = local.mysql_db["name"]
    db_table      = local.mysql_db["table"]
    db_port       = local.mysql_db["port"]
    app_port      = local.app1_mapped_port
    dns_domain    = local.dns_domain
    dns_zone_id   = local.dns_zone_id
  } 
}
// Create nginx config
data "template_file" "srv_user_data_nginx_config" {
  template = file("./templates/nginx_config.tpl")
  vars = {
    lab_token     = local.lab_token
    random_url_db = local.random_url_db
  }
}
// Create nginx html
data "template_file" "srv_user_data_nginx_html" {
  template = file("./templates/nginx_html.tpl")
  vars = {
    lab_fqdn = local.lab_fqdn
  }
}

# Create the IAM role/profile for the API Call
// Create role
resource "aws_iam_role" "lab-portal-role" {
  name = "${local.prefix}-lab-portal-apicall-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
// Create instance IAM profile
resource "aws_iam_instance_profile" "lab-portal-apicall-profile" {
  name = "${local.prefix}-lab-portal-apicall-profile"
  role = aws_iam_role.lab-portal-role.name
}
// Create policy
resource "aws_iam_policy" "lab-portal-apicall-policy" {
  name        = "${local.prefix}-lab-portal-apicall-policy"
  path        = "/"
  description = "Policies for the FGT api-call Role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadEC2Resources",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "eks:ListClusters"
            ],
            "Resource": "*"
        },
        {
            "Sid": "DNSNewRecordSet",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/${local.dns_zone_id}",
            "Condition": {
                "ForAllValues:StringLike": {
                    "route53:ChangeResourceRecordSetsNormalizedRecordNames": [
                        "fortixpert*.${local.dns_domain}"
                    ]
                }
            }
        }
    ]
}
EOF
}
// Create policy attachment
resource "aws_iam_policy_attachment" "lab-portal-apicall-attach" {
  name       = "${local.prefix}-lab-portal-apicall-attachment"
  roles      = [aws_iam_role.lab-portal-role.name]
  policy_arn = aws_iam_policy.lab-portal-apicall-policy.arn
}