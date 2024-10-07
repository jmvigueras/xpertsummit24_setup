variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type    = string
  default = "terraform"
}

variable "tags" {
  description = "Tags for created resources"
  type        = map(any)
  default = {
    project = "terraform"
  }
}

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type    = string
  default = null
}

variable "azs" {
  description = "Availability zones where Fortigates will be deployed"
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1c"]
}

variable "admin_cidr" {
  description = "CIDR for the administrative access to Fortigates"
  type    = string
  default = "0.0.0.0/0"
}

variable "cidr" {
  description = "CIDR for the VPC"
  type    = string
  default = "172.20.0.0/23"
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type    = list(string)
  default = ["public", "bastion"]
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type    = list(string)
  default = ["private", "tgw"]
}