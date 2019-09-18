
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    # using just ubuntu here will result in the above error UnsupportedOperation
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test_instance" {
  tenancy = "default"
  ami           = "${data.aws_ami.ubuntu.id}"
  availability_zone = "${var.region}a"
  instance_type = "t2.nano"
  credit_specification {
    cpu_credits = "standard"
  }

  subnet_id   = "${aws_subnet.test_subnet.id}"
  # DO NOT USE security_groups, because this would result in EC2-Classic instance
  # instead of EC2 instance https://github.com/hashicorp/terraform/issues/14416
  vpc_security_group_ids = [
    "${aws_security_group.test_allow_ssh_sg.id}",
    "${aws_security_group.test_allow_icmp_sg.id}"
  ]
  key_name = "${aws_key_pair.test_ssh_key.key_name}"
  # this cannot be set on aws_network_interface, thus we do not use
  # aws_network_interface here
  associate_public_ip_address = true

  tags = {
    # this has to start with Upper letter
    Name = "ec2-ansible-test"
    createdBy = "edu-aws"
  }
}
output "ec2_public_ip" {
  value = "${aws_instance.test_instance.public_ip}"
}
resource "null_resource" "wait_for_vm" {
  # TODO
  depends_on = ["aws_instance.test_instance"]
  connection {
    type = "ssh"
    host = "${aws_instance.test_instance.public_ip}"
    private_key = "${file("${var.ssh_keys_path}/test_id_rsa")}"
    user = "ubuntu"
  }

  # this will exit 1 if there is no internet connection
  # (since we use ping, we have to use the security group that allows ICMP)
  provisioner "remote-exec" {
    #inline = ["ping google.com -c 1 -W 1 && { echo 'Instance is ready'; } || exit 1 "]
    inline = ["echo 'Instance is ready'"]
  }
}
