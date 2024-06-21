#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "zorak" {
  ami           = local.ami_id
  instance_type = local.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = local.tags
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.example.id
}
output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}