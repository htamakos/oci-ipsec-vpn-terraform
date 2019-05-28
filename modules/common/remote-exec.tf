data "template_file" "sysctl" {
  template = "${file("${path.module}/../../templates/libreswan/sysctl.conf.tmp")}"
}

data "template_file" "ipsec_conf" {
  template = "${file("${path.module}/../../templates/libreswan/ipsec.conf.tmp")}"

  vars = {
    onp_pub_instance_private_ip = "${var.onp_pub_instance_pri_ip}"
    onp_pub_instance_pub_ip     = "${var.onp_pub_instance_pub_ip}"
    ipsec_connections_ip1       = "${var.ipsec_connections_ip1}"
    ipsec_connections_ip2       = "${var.ipsec_connections_ip2}"
  }
}

data "template_file" "ipsec_secrets" {
  template = "${file("${path.module}/../../templates/libreswan/ipsec.secrets.tmp")}"

  vars = {
    onp_pub_instance_pub_ip = "${var.onp_pub_instance_pub_ip}"
    ipsec_connections_ip1   = "${var.ipsec_connections_ip1}"
    ipsec_connections_ip2   = "${var.ipsec_connections_ip2}"
    ipsec_shared_secrets    = "${var.ipsec_shared_secrets}"
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
      host        = "${var.onp_pub_instance_pub_ip}"
      user        = "${var.ssh_user}"
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
      host        = "${var.onp_pub_instance_pub_ip}"
      user        = "${var.ssh_user}"
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
      host        = "${var.onp_pub_instance_pub_ip}"
      user        = "${var.ssh_user}"
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
      host        = "${var.onp_pub_instance_pub_ip}"
      user        = "${var.ssh_user}"
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
      host        = "${var.onp_pub_instance_pub_ip}"
      user        = "${var.ssh_user}"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "sudo mv /tmp/id_rsa /home/${var.ssh_user}/.ssh/id_rsa",
      "sudo chown ${var.ssh_user} /home/${var.ssh_user}/.ssh/id_rsa",
      "sudo chmod 400 /home/${var.ssh_user}/.ssh/id_rsa",
      "sudo systemctl stop firewalld",
      "sudo setenforce 0",
      "sudo yum install -y libreswan",
      "sudo mv /tmp/ipsec.conf /etc/ipsec.d/ipsec.conf",
      "sudo mv /tmp/ipsec.secrets /etc/ipsec.d/oci.secrets",
      "sudo systemctl start ipsec",
      "sudo ip route | grep ${var.cloud_vcn_cidr} &> /dev/null",
      "route_check=$?",
      "if [ $route_check -ne 0 ]; then sleep 10; fi" ,
      "sudo ip link show | grep vti01",
      "vti01_check=$?",
      "if [ $vti01_check -eq 0 ]; then vti01_str='nexthop dev vti01'; else vti01_str=''; fi",
      "sudo ip link show | grep vti02",
      "vti02_check=$?",
      "if [ $vti02_check -eq 0 ]; then vti02_str='nexthop dev vti02'; else vti02_str=''; fi",
      "if [ $route_check -ne 0 ] && [ $vti01_check -eq 0 -o $vti02_check -eq 0 ]; then sleep 10 && sudo ip route add ${var.cloud_vcn_cidr} $vti01_str $vti02_str; fi",
    ]
  }
}
