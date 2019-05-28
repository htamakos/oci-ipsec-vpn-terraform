# Compute
resource "aws_instance" "pub_instance" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.pub_subnet.id}"

  private_ip = "${var.pub_instance_private_ip}"

  associate_public_ip_address = true
  security_groups = [
    "${aws_security_group.sg.id}"
  ]
  key_name = "${aws_key_pair.auth.id}"

  credit_specification {
    cpu_credits = "unlimited"
  }

  lifecycle {
    "ignore_changes" =  ["security_groups"]
  }
  
  tags {
    Name = "${var.name_prefix}_pub_instance"
  }
}

## SSH KEYS
resource "aws_key_pair" "auth" {
  key_name = "${var.name_prefix}_sshkey"
  public_key = "${var.ssh_public_key}"
}

