variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

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

# Networking
variable "onp_vcn_cidr_block" {
  default = "10.0.0.0/16"
}

variable "onp_pub_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "onp_pub_instance_pri_ip" {
  default = "10.0.1.11"
}

variable "cloud_vcn_cidr_block" {
  default = "172.168.0.0/16"
}

variable "cloud_pub_subnet_cidr" {
  default = "172.168.1.0/24"
}

variable "cloud_pub_instance_pri_ip" {
  default = "172.168.1.11"
}
