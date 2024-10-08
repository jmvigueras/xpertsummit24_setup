#-----------------------------------------------------------------------
# Necessary resources
#
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
// Create key-pair
resource "aws_key_pair" "r1_keypair" {
  key_name   = "${local.prefix}-r1-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "aws_key_pair" "r2_keypair" {
  provider = aws.r2

  key_name   = "${local.prefix}-r2-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "aws_key_pair" "r3_keypair" {
  provider = aws.r3

  key_name   = "${local.prefix}-r3-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "aws_key_pair" "hub_keypair" {
  provider = aws.r4

  key_name   = "${local.prefix}-hub-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}