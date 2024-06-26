#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "zorak" {
  ami           = local.Zorak.ami_id
  instance_type = local.Zorak.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = local.Zorak.tags
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.zorak.id
}
output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.zorak.public_ip
}