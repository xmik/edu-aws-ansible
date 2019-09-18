resource "aws_key_pair" "test_ssh_key" {
  key_name   = "test_ssh_key"
  public_key = file("${var.ssh_keys_path}/test_id_rsa.pub")
}
