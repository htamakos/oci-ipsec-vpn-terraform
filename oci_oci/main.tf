module "oci_onp" {
  source                  = "../modules/oci_pubpri_network_and_computes"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  fingerprint             = "${var.fingerprint}"
  private_key_path        = "{$var.private_key_path}"
  region                  = "${var.region_onp}"
  compartment_id          = "${oci_identity_compartment.compartment.id}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  vcn_cidr_block          = "10.0.0.0/16"
  pub_subnet_cidr         = "10.0.1.0/24"
  pri_subnet_cidr         = "10.0.2.0/24"
  pub_instance_private_ip = "10.0.1.11"
  pri_instance_private_ip = "10.0.2.11"
  pri_instance_private_ip = "10.0.1.12"
  name_prefix             = "${var.name_prefix}_${local.onp_env}"
  env                     = "${local.onp_env}"
}

module "oci_cloud" {
  source                  = "../modules/oci_pubpri_network_and_computes"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  fingerprint             = "${var.fingerprint}"
  private_key_path        = "{$var.private_key_path}"
  region                  = "${var.region_cloud}"
  compartment_id          = "${oci_identity_compartment.compartment.id}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  vcn_cidr_block          = "172.168.0.0/16"
  pub_subnet_cidr         = "172.168.1.0/24"
  pri_subnet_cidr         = "172.168.2.0/24"
  onp_subnet_cidr         = "10.0.0.0/16"
  pub_instance_private_ip = "172.168.1.11"
  pri_instance_private_ip = "172.168.2.11"
  cpe_ip_address          = "${module.oci_onp.pub_instance_pub_ip}"
  name_prefix             = "${var.name_prefix}_${local.cloud_env}"
  env                     = "${local.cloud_env}"
}

## Data Sources
data "oci_core_ipsec_connection_tunnels" "ipsec_cons" {
  ipsec_id = "${module.oci_cloud.ipsec_id}"
}

## Outputs
output "ADs" {
  value = "${module.oci_cloud.ADs}"
}

output "instance_ips" {
  value = "${map(
    "onp_pub_instance_ip", module.oci_onp.pub_instance_pub_ip,
    "cloud_pub_instance_ip", module.oci_cloud.pub_instance_pub_ip,
  )}"
}

output "ipsec_id" {
  value = "${map(
    "ipsec_tunnel_1", data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.0.vpn_ip,
    "ipsec_tunnel_2", data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.1.vpn_ip
  )}"
}
