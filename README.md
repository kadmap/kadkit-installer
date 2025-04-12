# KadKit Installer

This repository contains the official installer for the KadMap CLI tool. The installer automates the download and setup process for KadMap on Linux and macOS systems.

## Features

- Automatic platform detection (OS and architecture)
- Dependency checking
- Installation to standard system directories
- Automatic PATH configuration
- Configuration template setup
- Multiple authentication methods for private repositories
  - GitHub CLI authentication
  - Personal access token

## Requirements

- Bash shell
- curl
- tar
- gzip
- GitHub CLI (optional, for seamless authentication)
- AWS CLI (optional, for ECR access)
- Docker (optional, for ECR access)

## Usage

### Quick Install

```bash
# Install the latest version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadkit-installer/main/install.sh | bash

# Install a specific version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadkit-installer/main/install.sh | VERSION=v0.0.1 bash

# Install with a GitHub token (for private repositories without GitHub CLI)
curl -fsSL https://raw.githubusercontent.com/kadmap/kadkit-installer/main/install.sh | GITHUB_TOKEN=your_token bash
```

### Manual Install

1. Clone this repository
2. Run the installation script

```bash
git clone https://github.com/kadmap/kadkit-installer.git
cd kadkit-installer
./install.sh
```

## Installation Details

The installer:

1. Detects your operating system and architecture
2. Verifies required dependencies
3. Downloads the appropriate KadMap binary from GitHub releases
4. Installs the binary to `/usr/local/bin` (or another location if configured)
5. Sets up configuration templates in `~/.kadmap`
6. Updates your PATH if necessary

## Authentication Methods

The installer supports multiple methods for accessing private GitHub repositories:

### 1. GitHub CLI (Recommended)

If you have GitHub CLI installed and authenticated, the installer will automatically use it to download releases.

#### Setting Up GitHub CLI

For Ubuntu/Debian:
```bash
# Install GitHub CLI
sudo apt update
sudo apt install gh

# Authenticate (follow the prompts)
gh auth login
```

For macOS:
```bash
# Install GitHub CLI
brew install gh

# Authenticate (follow the prompts)
gh auth login
```

During authentication:
1. Choose "GitHub.com" when prompted
2. Choose your preferred protocol (HTTPS is recommended)
3. Select "Login with a web browser" option
4. A one-time code will be displayed - copy it
5. Your browser will open. Paste the code there and authorize GitHub CLI
6. Verify your authentication with `gh auth status`

After successful authentication:
```bash
# Then run the installer (no token needed)
./install.sh
```

### 2. Personal Access Token

If GitHub CLI is not available, you can provide a GitHub Personal Access Token:

```bash
# Run with token as environment variable
GITHUB_TOKEN=your_token ./install.sh
```

Alternatively, you can edit the script to include your token permanently:

```bash
# In install.sh, edit this line:
GITHUB_TOKEN="${GITHUB_TOKEN:-"your_personal_access_token"}"
```

## Docker Setup

Docker is required for working with container images and ECR. Follow these steps to install Docker:

### Installing Docker on Ubuntu/Debian

```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository for Ubuntu
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add your user to the docker group to run Docker without sudo
sudo usermod -aG docker $USER

# Apply the new group (alternatively, you can log out and log back in)
newgrp docker

# Verify Docker installation
docker --version
docker run hello-world
```

### Installing Docker on macOS

```bash
# Install Docker Desktop via Homebrew
brew install --cask docker

# Start Docker Desktop application
open /Applications/Docker.app

# Verify Docker installation
docker --version
docker run hello-world
```

After installing Docker, you'll need to log out and log back in (or restart your system) to apply the group changes on Linux systems.

## ECR Setup (Amazon Elastic Container Registry)

If you need to use Amazon ECR for container management, follow these steps:

### 1. Install AWS CLI

```bash
# Download AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install required dependencies
sudo apt install unzip

# Extract and install
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### 2. Configure AWS Credentials

```bash
# Run AWS configure and enter your credentials when prompted
aws configure
```

Enter the following information when prompted:
- AWS Access Key: `YOUR_AWS_ACCESS_KEY`
- AWS Secret Access Key: `YOUR_AWS_SECRET_ACCESS_KEY`
- Default region name: `YOUR_AWS_REGION` (e.g., us-east-1, us-west-2)
- Default output format: (press Enter for default)

### 3. Authenticate Docker with ECR

```bash
# Retrieve an authentication token and authenticate your Docker client to your registry
aws ecr get-login-password --region YOUR_AWS_REGION | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_AWS_REGION.amazonaws.com
```

After this setup, you'll be able to push and pull images from the ECR repository.




## Troubleshooting

If you encounter issues during installation:

- **Permission denied errors**: The script will attempt to use `sudo` when necessary
- **PATH issues**: You may need to restart your terminal or source your shell configuration file
- **Download failures**: 
  - For GitHub CLI: Verify you're logged in with `gh auth status`
  - For token: Verify your GitHub token has the correct permissions
  - If using a private repo, make sure you have access to it
- **AWS/ECR issues**:
  - Verify AWS credentials with `aws sts get-caller-identity`
  - Make sure Docker is running before authenticating with ECR
  - Check ECR permissions in your AWS IAM console

## License

This installer is part of the KadKit project and is licensed under the same terms. 