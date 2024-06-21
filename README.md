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
# Update and upgrade the system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Install Git
apt-get install -y git

# Install Neofetch
apt-get install -y neofetch

# Create a new user for GitHub Actions
USERNAME="github_actions"
USER_HOME="/home/${USERNAME}"
USER_SSH_DIR="${USER_HOME}/.ssh"

# Create user and home directory
useradd -m -s /bin/bash ${USERNAME}

# Add user to the docker group
usermod -aG docker ${USERNAME}

# Set up SSH for the new user
mkdir -p ${USER_SSH_DIR}
chmod 700 ${USER_SSH_DIR}
touch ${USER_SSH_DIR}/authorized_keys
chmod 600 ${USER_SSH_DIR}/authorized_keys

# Copy the public key to the authorized_keys file
echo "YOUR_GITHUB_ACTIONS_PUBLIC_KEY_HERE" > ${USER_SSH_DIR}/authorized_keys

# Set ownership of the SSH directory and files
chown -R ${USERNAME}:${USERNAME} ${USER_SSH_DIR}

# Output message
echo "Basic setup is complete. Docker, Git, and Neofetch are installed. User ${USERNAME} is created for SSH access."
```

### Summary

1. **`locals.defaults.tf`**: Contains local variables for Terraform.
2. **`deploy.yaml`**: Defines GitHub Actions workflow for deployment.
3. **`setup.sh`**: Script for setting up the EC2 instance with necessary software and user configurations.

By creating these files and including them in `.gitignore`, you ensure that sensitive information and environment-specific configurations are not exposed in your repository. This approach provides a flexible and secure way to manage your infrastructure and deployment processes.