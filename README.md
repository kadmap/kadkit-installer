# KadMap Installer

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

## Usage

### Quick Install

```bash
# Install the latest version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadmap-installer/main/install.sh | bash

# Install a specific version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadmap-installer/main/install.sh | VERSION=v0.0.1 bash

# Install with a GitHub token (for private repositories without GitHub CLI)
curl -fsSL https://raw.githubusercontent.com/kadmap/kadmap-installer/main/install.sh | GITHUB_TOKEN=your_token bash
```

### Manual Install

1. Clone this repository
2. Run the installation script

```bash
git clone https://github.com/kadmap/kadmap-installer.git
cd kadmap-installer
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

If you have GitHub CLI installed and authenticated, the installer will automatically use it to download releases:

```bash
# Install GitHub CLI
# For Ubuntu
sudo apt install gh

# For macOS
brew install gh

# Authenticate (follow the prompts)
gh auth login

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

## Customization

The installer can be customized by modifying the following variables at the top of the script:

- `CLI_NAME`: The name of the executable (default: "kadmap")
- `CLI_VERSION`: Version to install (default: "latest" or value of VERSION environment variable)
- `INSTALL_DIR`: Installation directory (default: "/usr/local/bin")
- `CONFIG_DIR`: Configuration directory (default: "$HOME/.kadmap")
- `GITHUB_REPO`: GitHub repository to download from (default: "kadmap/devtool")
- `GITHUB_TOKEN`: GitHub Personal Access Token (default: empty, can be set via environment variable)

## Troubleshooting

If you encounter issues during installation:

- **Permission denied errors**: The script will attempt to use `sudo` when necessary
- **PATH issues**: You may need to restart your terminal or source your shell configuration file
- **Download failures**: 
  - For GitHub CLI: Verify you're logged in with `gh auth status`
  - For token: Verify your GitHub token has the correct permissions

## License

This installer is part of the KadMap project and is licensed under the same terms. 