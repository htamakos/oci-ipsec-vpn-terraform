variable "onp_pub_instance_pri_ip" {}
variable "onp_pub_instance_pub_ip" {}
variable "ipsec_connections_ip1" {}
variable "ipsec_connections_ip2" {}

variable "ipsec_shared_secrets" {
  default = "oracle"
}

variable "ssh_private_key" {}
variable "cloud_vcn_cidr" {}
variable "ssh_user" {}
