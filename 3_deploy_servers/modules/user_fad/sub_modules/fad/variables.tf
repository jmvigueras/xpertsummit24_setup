variable "prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "terraform"
}

variable "suffix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type        = string
  default     = "1"
}

variable "tags" {
  description = "Tags for created resources"
  type        = map(any)
  default     = {}
}

variable "region" {
  description = "AWS region, necessay if provider alias is used"
  type        = string
  default     = null
}

variable "ni_id" {
  description = "Network Interface ID used if provided"
  type        = string
  default     = null
}

variable "private_ips" {
  description = "Private IP used to create Network Interface"
  type        = list(string)
  default     = null
}

variable "num_private_ips" {
  description = "Number of asignated private IPs"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "FortiAnalyzer instance type"
  type        = string
  default     = "m5.large"
}

variable "subnet_id" {
  description = "Subnet ID, necessary if ni_id it is not provided to create NI"
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "CIDR of the subnet, use to assign NI private IP"
  type        = string
  default     = null
}

variable "config_eip" {
  description = "Boolean to enable/disable EIP configuration"
  type        = bool
  default     = true
}

variable "cidr_host" {
  description = "First IP number of the network to assign"
  type        = number
  default     = 10
}

variable "security_groups" {
  description = "List of security groups to assign to NI"
  type        = list(string)
  default     = null
}

variable "keypair" {
  description = "AWS key pair name"
  type        = string
  default     = null
}

variable "iam_profile" {
  description = "IAM profile to assing to the instance"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "fad username used for API key"
  type        = string
  default     = "admin"
}

variable "fad_extra_config" {
  description = "Extra config to add to bootstrap user-data"
  type        = string
  default     = ""
}

variable "fad_version" {
  description = "FAD version"
  type        = string
  default     = "7.2.0"
}

variable "fad_btw" {
  description = "FAD Bandwith 100mbps, 200mbps, 500mbps, 1gbps"
  type        = string
  default     = "1gbps"
}

variable "fad_ami_id" {
  description = "Provide AMI ID for custom deployments"
  type        = string
  default     = null
}

variable "rsa-public-key" {
  description = "SSH RSA public key for KeyPair"
  type        = string
  default     = null
}

variable "license_type" {
  description = "License Type to create FortiGate-VM"
  type        = string
  default     = "payg"
}

variable "license_file" {
  description = "License file path"
  type        = string
  default     = "./licenses/licenseFAD.lic"
}

