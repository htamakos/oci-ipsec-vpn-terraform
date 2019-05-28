module "oci_onp" {
  source                  = "../modules/oci_pub_network_and_computes"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  fingerprint             = "${var.fingerprint}"
  private_key_path        = "{$var.private_key_path}"
  region                  = "${var.region_onp}"
  compartment_id          = "${oci_identity_compartment.compartment.id}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  vcn_cidr_block          = "${var.onp_vcn_cidr_block}"
  pub_subnet_cidr         = "${var.onp_pub_subnet_cidr}"
  pub_instance_private_ip = "${var.pub_instance_pri_ip}"
  name_prefix             = "${var.name_prefix}_${local.onp_env}"
  env                     = "${local.onp_env}"
}

module "oci_cloud" {
  source                  = "../modules/oci_pub_network_and_computes"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  fingerprint             = "${var.fingerprint}"
  private_key_path        = "{$var.private_key_path}"
  region                  = "${var.region_cloud}"
  compartment_id          = "${oci_identity_compartment.compartment.id}"
  ssh_public_key          = "${var.ssh_public_key}"
  ssh_private_key         = "${var.ssh_private_key}"
  vcn_cidr_block          = "${var.cloud_vcn_cidr_block}"
  pub_subnet_cidr         = "${var.cloud_pub_subnet_cidr}"
  pub_instance_private_ip = "${var.cloud_pub_instance_pri_ip}"
  onp_subnet_cidr         = "${var.onp_vcn_cidr_block}"
  cpe_ip_address          = "${module.oci_onp.pub_instance_pub_ip}"
  name_prefix             = "${var.name_prefix}_${local.cloud_env}"
  env                     = "${local.cloud_env}"
}

module "common" {
  source                  = "../modules/common"
  onp_pub_instance_pri_ip = "${module.oci_onp.pub_instance_pri_ip}"
  onp_pub_instance_pub_ip = "${module.oci_onp.pub_instance_pub_ip}"
  ipsec_connections_ip1   = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.0.vpn_ip}"
  ipsec_connections_ip2   = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.1.vpn_ip}"
  ssh_private_key         = "${var.ssh_private_key}"
  ssh_user                = "opc"
  cloud_vcn_cidr          = "${module.oci_cloud.vcn_cidr}"
}

## Provider
provider "oci" {
  alias            = "home"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region_home}"
}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region_cloud}"
}

## Data Sources
data "oci_core_ipsec_connection_tunnels" "ipsec_cons" {
  ipsec_id = "${module.oci_cloud.ipsec_id}"
}

## Outputs
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
