# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

resource "aws_key_pair" "deployer" {
  key_name   = local.key_name
  public_key = file(local.public_key_path)

  tags = local.tags
}