locals {
  Zorak = {
    region                     = "eu-central-1"
    instance_type              = "t2.micro"
    key_name                   = "zorak_ssh"
    ami_id                     = "ami-0d527b8c289b4af7f" # Ubuntu 20.04 LTS AMI for Frankfurt
    security_group_name        = "allow_ssh"
    security_group_description = "Allow SSH inbound traffic"
    ssh_ingress_cidr           = ["0.0.0.0/0"] # Allows SSH from anywhere, use with caution in production
    tags = {
      Name      = "Zorak"
      CreatedOn = substr(timestamp(), 0, 10) # Format: YYYY-MM-DD
    }
  }
}