# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = local.Zorak.key_name
  public_key = tls_private_key.key.public_key_openssh

  tags = local.Zorak.tags
}


output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}
output "ssh_url" {
  value = "ssh -i ${aws_key_pair.deployer.key_name}.pem ubuntu@${aws_instance.zorak.public_ip}"
  description = "SSH URL to connect to the instance"
}

resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${local.Zorak.key_name}.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content  = tls_private_key.key.public_key_pem
  filename = "${local.Zorak.key_name}.pub"
  file_permission = "0600"
}
