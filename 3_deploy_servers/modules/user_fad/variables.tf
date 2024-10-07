variable "rsa_public_key" {
  type    = string
  default = "null"
}
variable "api_key" {
  type    = string
  default = "null"
}
variable "key_pair_name" {
  type    = string
  default = "null"
}
variable "prefix" {
  type    = string
  default = "xps24"
}
variable "region" {
  type    = map(string)
  default = null
}
variable "user_fad_ni_ids" {
  type    = map(string)
  default = null
}
variable "user_fad_ni_ips" {
  type    = map(map(string))
  default = null
}
variable "fad_ami_id" {
  type    = string
  default = null
}
variable "instance_type" {
  type    = string
  default = "m5.large"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "user_fad_iams" {
  type    = map(string)
  default = null
}