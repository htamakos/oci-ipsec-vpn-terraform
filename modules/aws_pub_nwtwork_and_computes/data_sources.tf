data "aws_instance" "pub_instance" {
  instance_id = "${aws_instance.pub_instance.id}"
}

data "aws_vpc" "vpc" {
  id = "${aws_vpc.vpc.id}"
}
