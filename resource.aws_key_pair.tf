# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

resource "aws_key_pair" "deployer" {
  key_name   = local.Zorak.key_name
  public_key = file(local.Zorak.public_key_path)

  tags = local.Zorak.tags
}

output "ssh_url" {
  value = "ssh -i ${aws_key_pair.deployer.key_name}.pem ec2-user@${aws_instance.zorak.public_ip}"
  description = "SSH URL to connect to the instance"
}