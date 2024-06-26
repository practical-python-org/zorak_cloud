Zorak Cloud Infra

### Step-by-Step Guide

#### 1. Create `locals.defaults.tf`
This file will contain the local variables for your Terraform configuration. By adding it to `.gitignore`, you can ensure that sensitive or environment-specific information is not committed to your repository.

```sh
# Create locals.defaults.tf
touch locals.defaults.tf
```

#### 2. Create `deploy.yaml`
This file will define the GitHub Actions workflow for deploying your application. By including it in `.gitignore`, you can manage deployment secrets and configurations locally without exposing them in your repository.

```sh
# Create deploy.yaml
touch deploy.yaml
```

#### 3. Create `setup.sh`
This script will be used to set up the necessary environment on your EC2 instance, such as installing required software and configuring user access. By ignoring this file, you can keep setup specifics private and customizable.

```sh
# Create setup.sh
touch setup.sh
```

### Documentation

#### `locals.defaults.tf`
**Purpose**: This file contains local variables for your Terraform configuration. These variables include region, instance type, key names, security group details, and other configurations that you might want to reuse across your Terraform files.

**Example Content**:
```hcl
locals {
  region                     = "eu-central-1"
  instance_type              = "t2.micro"
  key_name                   = "deployer-key"
  public_key_path            = "~/.ssh/id_rsa.pub"
  ami_id                     = "ami-0d527b8c289b4af7f"  # Ubuntu 20.04 LTS AMI for Frankfurt
  security_group_name        = "allow_ssh"
  security_group_description = "Allow SSH inbound traffic"
  ssh_ingress_cidr           = ["0.0.0.0/0"]  # Allows SSH from anywhere, use with caution in production
  creation_date              = substr(timestamp(), 0, 10)  # Format: YYYY-MM-DD
  tags = {
    Name           = "ExampleInstance"
    CreationDate   = local.creation_date
  }
}
```

#### `deploy.yaml`
**Purpose**: This file defines the GitHub Actions workflow for your CI/CD pipeline. It specifies the steps to build, test, and deploy your application whenever you push changes to your repository.

**Example Content**:
```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Install SSH Key
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa

    - name: Add SSH Key to Agent
      run: |
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa

    - name: SSH into EC2 and Run Commands
      run: |
        ssh -o StrictHostKeyChecking=no github_actions@${{ secrets.EC2_PUBLIC_IP }} << 'EOF'
          git clone https://github.com/your/repo.git
          cd repo
          docker-compose up -d
          neofetch
        EOF
```

#### `setup.sh`
**Purpose**: This script is used for setting up your EC2 instance. It installs necessary packages, creates a user, and configures SSH access. This script ensures that the environment is prepared for deployment and development.

**Example Content**:
```bash
#!/bin/bash
TOKEN="Some_discrod_token"

# Docker and Docker-Compose
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl start docker && sudo systemctl enable docker

# Message of the day -> Neofetch
sudo apt install -y git neofetch
sudo rm -r /etc/update-motd.d/*
sudo mkdir /etc/update-motd.d
sudo bash -c 'cat <<EOF > /etc/update-motd.d/00-neofetch
#!/bin/bash
/usr/bin/neofetch
EOF'
sudo chmod +x /etc/update-motd.d/00-neofetch
sudo run-parts /etc/update-motd.d/

# Zorak
git clone https://github.com/practical-python-org/ZorakBot.git
cd ZorakBot && cp .env.example .env
sed -i "s/^DISCORD_TOKEN=.*/DISCORD_TOKEN=${TOKEN}/" ".env"

docker compose up -d

```

### Summary

1. **`locals.defaults.tf`**: Contains local variables for Terraform.
2. **`deploy.yaml`**: Defines GitHub Actions workflow for deployment.
3. **`setup.sh`**: Script for setting up the EC2 instance with necessary software and user configurations.

By creating these files and including them in `.gitignore`, you ensure that sensitive information and environment-specific configurations are not exposed in your repository. This approach provides a flexible and secure way to manage your infrastructure and deployment processes.