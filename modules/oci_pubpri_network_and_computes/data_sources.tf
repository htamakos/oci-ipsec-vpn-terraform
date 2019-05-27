# Compute
data "oci_core_images" "images" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"

  operating_system         = "Oracle Linux"
  operating_system_version = "7.6"
  shape                    = "${var.instance_shape}"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  state                    = "AVAILABLE"
}

data "oci_core_instance" "pub_instance" {
  provider    = "oci.target"
  instance_id = "${oci_core_instance.pub_instance.id}"
}

# Common
data "oci_identity_availability_domains" "ADs" {
  provider       = "oci.target"
  compartment_id = "${var.tenancy_ocid}"
}

# IPSec
data "oci_core_ipsec_connection_tunnels" "ipsec" {
  count = "${var.env == "cloud" ? 1 : 0}"

  provider = "oci.target"
  ipsec_id = "${oci_core_ipsec.ip_sec_connection.id}"
}
