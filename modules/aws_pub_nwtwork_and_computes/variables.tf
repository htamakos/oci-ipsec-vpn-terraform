# Common
variable "aws_access_key" {}

variable "aws_secret_key" {}
variable "region" {}
variable "name_prefix" {}
variable "env" {}

# Networking
variable "public_cidr_block" {
  default = "0.0.0.0/0"
}

variable "vpc_cidr_block" {}
variable "pub_subnet_cidr" {}

# Compute
variable "ssh_public_key" {}
variable "pub_instance_private_ip" {}
variable "ami" {
  default = "ami-00d101850e971728d"
}
variable "instance_type" {
  default = "t2.micro"
}

