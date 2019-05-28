output "pub_instance_pub_ip" {
  value = "${data.aws_instance.pub_instance.public_ip}"
}

output "pub_instance_pri_ip" {
  value = "${data.aws_instance.pub_instance.private_ip}"
}

output "vcn_cidr" {
  value = "${data.aws_vpc.vpc.cidr_block}"
}
