### Virtual Cloud Network
resource "oci_core_vcn" "vcn" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"
  cidr_block     = "${var.vcn_cidr_block}"
  display_name   = "${var.name_prefix}_vcn"
  dns_label      = "${var.env}vcn"
}

### Internet Gateway
resource "oci_core_internet_gateway" "ig" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_ig"
}

### NAT Gateway
resource "oci_core_nat_gateway" "ng" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_ng"
}

## DRG
resource "oci_core_drg" "drg" {
  count          = "${var.env == "cloud" ? 1 : 0}"
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"

  display_name = "${var.name_prefix}_drg"
}

resource "oci_core_drg_attachment" "drg_attachment" {
  count    = "${var.env == "cloud" ? 1 : 0}"
  provider = "oci.target"
  drg_id   = "${oci_core_drg.drg.id}"
  vcn_id   = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_drg_attachment"
}

### Route Table
#### Public
resource "oci_core_route_table" "pub_rt" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"

  route_rules {
    destination       = "${var.public_cidr_block}"
    network_entity_id = "${oci_core_internet_gateway.ig.id}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name_prefix}_pub_rt"
}

#### Private
resource "oci_core_route_table" "pri_rt" {
  provider       = "oci.target"
  count          = "${var.env == "cloud" ? 0 : 1}"
  compartment_id = "${var.compartment_id}"

  route_rules {
    destination       = "${var.public_cidr_block}"
    network_entity_id = "${oci_core_nat_gateway.ng.id}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name_prefix}_pri_rt"
}

resource "oci_core_route_table" "pri_rt_with_drg" {
  provider       = "oci.target"
  count          = "${var.env == "cloud" ? 1 : 0}"
  compartment_id = "${var.compartment_id}"

  route_rules {
    destination       = "${var.public_cidr_block}"
    network_entity_id = "${oci_core_nat_gateway.ng.id}"
  }

  route_rules {
    destination       = "${var.onp_subnet_cidr}"
    network_entity_id = "${oci_core_drg.drg.id}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name_prefix}_pri_rt_with_drg"
}

### SecurityLists
resource "oci_core_security_list" "pub_sl" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"

  # Outbound
  egress_security_rules {
    destination = "${var.public_cidr_block}"
    protocol    = "all"
  }

  # Inbound
  ## SSH
  ingress_security_rules {
    protocol = 6
    source   = "${var.public_cidr_block}"

    tcp_options {
      max = 22
      min = 22
    }
  }

  ## ICMP
  ingress_security_rules {
    protocol = 1
    source   = "${var.public_cidr_block}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name_prefix}_pub_sl"
}

resource "oci_core_security_list" "pri_sl" {
  provider       = "oci.target"
  compartment_id = "${var.compartment_id}"

  # Outbound
  egress_security_rules {
    destination = "${var.public_cidr_block}"
    protocol    = "all"
  }

  # Inbound
  ## SSH
  ingress_security_rules {
    protocol = 6
    source   = "${var.public_cidr_block}"

    tcp_options {
      max = 22
      min = 22
    }
  }

  ## IPSEC 
  ### TCP
  ingress_security_rules {
    protocol = 6
    source   = "${var.public_cidr_block}"

    tcp_options {
      max = 500
      min = 500
    }
  }

  ingress_security_rules {
    protocol = 6
    source   = "${var.public_cidr_block}"

    tcp_options {
      max = 4500
      min = 4500
    }
  }

  ### UDP
  ingress_security_rules {
    protocol = 17
    source   = "${var.public_cidr_block}"

    udp_options {
      max = 500
      min = 500
    }
  }

  ingress_security_rules {
    protocol = 17
    source   = "${var.public_cidr_block}"

    udp_options {
      max = 4500
      min = 4500
    }
  }

  ## ICMP
  ingress_security_rules {
    protocol = 1
    source   = "${var.public_cidr_block}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "${var.name_prefix}_pub_sl"
}

### Subnets
resource "oci_core_subnet" "pub_subnet" {
  provider          = "oci.target"
  cidr_block        = "${var.pub_subnet_cidr}"
  compartment_id    = "${var.compartment_id}"
  security_list_ids = ["${oci_core_security_list.pub_sl.id}"]
  vcn_id            = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_pub_subnet"
  dns_label    = "pub"

  prohibit_public_ip_on_vnic = false
  route_table_id             = "${oci_core_route_table.pub_rt.id}"
}

resource "oci_core_subnet" "pri_subnet" {
  count             = "${var.env == "cloud" ? 0 : 1}"
  provider          = "oci.target"
  cidr_block        = "${var.pri_subnet_cidr}"
  compartment_id    = "${var.compartment_id}"
  security_list_ids = ["${oci_core_security_list.pri_sl.id}"]
  vcn_id            = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_pri_subnet"
  dns_label    = "pri"

  prohibit_public_ip_on_vnic = true
  route_table_id             = "${oci_core_route_table.pri_rt.id}"
}

resource "oci_core_subnet" "pri_subnet_with_drg" {
  count             = "${var.env == "cloud" ? 1 : 0}"
  provider          = "oci.target"
  cidr_block        = "${var.pri_subnet_cidr}"
  compartment_id    = "${var.compartment_id}"
  security_list_ids = ["${oci_core_security_list.pri_sl.id}"]
  vcn_id            = "${oci_core_vcn.vcn.id}"

  display_name = "${var.name_prefix}_pri_subnet"
  dns_label    = "pri"

  prohibit_public_ip_on_vnic = true
  route_table_id             = "${oci_core_route_table.pri_rt_with_drg.id}"
}
