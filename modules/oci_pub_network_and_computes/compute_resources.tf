resource "oci_core_instance" "pub_instance" {
  provider            = "oci.target"
  count               = "${var.env == "cloud" ? 0 : 1}"
  compartment_id      = "${var.compartment_id}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.pub_subnet.id}"

    assign_public_ip = true
    hostname_label   = "${var.env}-pub-instance"
    private_ip       = "${var.pub_instance_private_ip}"
  }

  display_name   = "${var.name_prefix}_pub_instance"
  hostname_label = "${var.env}-pub-instance"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  source_details {
    source_id   = "${lookup(data.oci_core_images.images.images[0], "id")}"
    source_type = "image"
  }

  preserve_boot_volume = false
}

resource "oci_core_instance" "pub_instance_with_drg" {
  count               = "${var.env == "cloud" ? 1 : 0}"
  provider            = "oci.target"
  compartment_id      = "${var.compartment_id}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.pub_subnet_with_drg.id}"

    assign_public_ip = true
    hostname_label   = "${var.env}-pub-instance"
    private_ip       = "${var.pub_instance_private_ip}"
  }

  display_name   = "${var.name_prefix}_pub_instance"
  hostname_label = "${var.env}-pub-instance"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  source_details {
    source_id   = "${lookup(data.oci_core_images.images.images[0], "id")}"
    source_type = "image"
  }

  preserve_boot_volume = false
}
