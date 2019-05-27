# CPE
resource "oci_core_cpe" "cpe" {
    provider = "oci.target"
    count = "${var.env == "cloud" ? 1 : 0 }"

    compartment_id = "${var.compartment_id}"
    ip_address = "${var.cpe_ip_address}"

    display_name = "${var.name_prefix}_cpe"
}

# IPsec Connections
resource "oci_core_ipsec" "ip_sec_connection" {
    compartment_id = "${var.compartment_id}"
    provider = "oci.target"
    count = "${var.env == "cloud" ? 1 : 0 }"

    cpe_id = "${oci_core_cpe.cpe.id}"
    drg_id = "${oci_core_drg.drg.id}"
    static_routes = ["${var.onp_subnet_cidr}"]

    display_name = "${var.name_prefix}_ipsec"

    tunnel_configuration {
        shared_secret = "${var.ip_sec_shared_secret}"
    }

    tunnel_configuration {
        shared_secret = "${var.ip_sec_shared_secret}"
    }
}

