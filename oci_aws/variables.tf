variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region_home" {}
variable "region_cloud" {}
variable "region_onp" {}
variable "ssh_private_key" {}
variable "ssh_public_key" {}

variable "name_prefix" {
  default = "ocs"
}

variable "public_cidr_block" {
  default = "0.0.0.0/0"
}

locals {
  onp_env   = "onp"
  cloud_env = "cloud"
}
