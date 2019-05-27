# Common
variable "name_prefix" {
  default = "ocs"
}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "env" {}

# Identities
variable "compartment_id" {}

# Networking
variable "public_cidr_block" {
  default = "0.0.0.0/0"
}

variable "vcn_cidr_block" {}
variable "pub_subnet_cidr" {}
variable "pri_subnet_cidr" {}
variable "onp_subnet_cidr" {
  default = ""
}

# IPsec
variable "cpe_ip_address" {
  default = ""
}
variable "ip_sec_shared_secret" {
  default = "oracle"
}

# Compute
variable "ssh_private_key" {}
variable "ssh_public_key" {}
variable "instance_shape" {
  default = "VM.Standard2.1"
}
variable "instance_image_id" {
  default = ""
}

variable "pub_instance_private_ip" {}
variable "pri_instance_private_ip" {}

