output "vcn_id" {
  value = "${oci_core_vcn.vcn.id}"
}

output "ADs" {
  value = "${data.oci_identity_availability_domains.ADs.availability_domains}"
}

output "pub_instance_pub_ip" {
  value = "${data.oci_core_instance.pub_instance.public_ip}"
}

output "pub_instance_pri_ip" {
  value = "${data.oci_core_instance.pub_instance.private_ip}"
}

output "ipsec_id" {
  value = "${join(" ", oci_core_ipsec.ip_sec_connection.*.id)}"
}

output "vcn_cidr" {
  value = "${oci_core_vcn.vcn.cidr_block}"
}
