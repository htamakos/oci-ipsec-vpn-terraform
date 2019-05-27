data "template_file" "sysctl" {
  template = "${file("../templates/libreswan/sysctl.conf.tmp")}"
}

data "template_file" "ipsec_conf" {
  template = "${file("../templates/libreswan/ipsec.conf.tmp")}"

  vars = {
    onp_pub_instance_private_ip = "${module.oci_onp.pub_instance_pri_ip}"
    onp_pub_instance_pub_ip     = "${module.oci_onp.pub_instance_pub_ip}"
    ipsec_connections_ip1       = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.0.vpn_ip}"
    ipsec_connections_ip2       = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.1.vpn_ip}"
  }
}

data "template_file" "ipsec_secrets" {
  template = "${file("../templates/libreswan/ipsec.secrets.tmp")}"

  vars = {
    onp_pub_instance_pub_ip = "${module.oci_onp.pub_instance_pub_ip}"
    ipsec_connections_ip1   = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.0.vpn_ip}"
    ipsec_connections_ip2   = "${data.oci_core_ipsec_connection_tunnels.ipsec_cons.ip_sec_connection_tunnels.1.vpn_ip}"
    ipsec_shared_secrets    = "oracle"
  }
}

resource "null_resource" "sysctl" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${module.oci_onp.pub_instance_pub_ip}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${data.template_file.sysctl.rendered}"
    destination = "/tmp/sysctl.conf"
  }
}

resource "null_resource" "ipsec_conf" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${module.oci_onp.pub_instance_pub_ip}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${data.template_file.ipsec_conf.rendered}"
    destination = "/tmp/ipsec.conf"
  }
}

resource "null_resource" "ipsec_secrets" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${module.oci_onp.pub_instance_pub_ip}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${data.template_file.ipsec_secrets.rendered}"
    destination = "/tmp/ipsec.secrets"
  }
}

resource "null_resource" "ssh_private_key" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${module.oci_onp.pub_instance_pub_ip}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    content     = "${var.ssh_private_key}"
    destination = "/tmp/id_rsa"
  }
}

resource "null_resource" "provision" {
  triggers {
    build_number = "${timestamp()}"
  }

  depends_on = [
    "null_resource.ipsec_conf",
    "null_resource.ipsec_secrets",
    "null_resource.sysctl",
  ]

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${module.oci_onp.pub_instance_pub_ip}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "sudo mv /tmp/id_rsa /home/opc/.ssh/id_rsa",
      "sudo chown opc /home/opc/.ssh/id_rsa",
      "sudo chmod 400 /home/opc/.ssh/id_rsa",
      "sudo systemctl stop firewalld",
      "sudo setenforce 0",
      "sudo yum install -y libreswan",
      "sudo mv /tmp/ipsec.conf /etc/ipsec.d/ipsec.conf",
      "sudo mv /tmp/ipsec.secrets /etc/ipsec.d/oci.secrets",
      "sudo systemctl start ipsec",
      "sudo ip route | grep ${module.oci_cloud.vcn_cidr} &> /dev/null",
      "if [ $? -ne 0 ]; then sleep 10 && sudo ip route add ${module.oci_cloud.vcn_cidr} nexthop dev vti01 nexthop dev vti02; fi",
    ]
  }
}
