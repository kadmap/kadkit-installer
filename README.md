# KadMap Installer

This repository contains the official installer for the KadMap CLI tool. The installer automates the download and setup process for KadMap on Linux and macOS systems.

## Features

- Automatic platform detection (OS and architecture)
- Dependency checking
- Installation to standard system directories
- Automatic PATH configuration
- Configuration template setup

## Requirements

- Bash shell
- curl
- tar
- gzip

## Usage

### Quick Install

```bash
# Install the latest version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadmap-installer/main/install.sh | bash

# Install a specific version
curl -fsSL https://raw.githubusercontent.com/kadmap/kadmap-installer/main/install.sh | VERSION=v0.0.1 bash
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

## Private Repository Configuration

This installer is designed to work with private GitHub repositories. Before using, you need to:

1. Generate a GitHub Personal Access Token with `repo` permissions
2. Replace `your_personal_access_token` in the script with your actual token

```bash
# Example token configuration
local GITHUB_TOKEN="ghp_youractualtoken123456789"
```

## Customization

The installer can be customized by modifying the following variables at the top of the script:

- `CLI_NAME`: The name of the executable (default: "kadmap")
- `CLI_VERSION`: Version to install (default: "latest" or value of VERSION environment variable)
- `INSTALL_DIR`: Installation directory (default: "/usr/local/bin")
- `CONFIG_DIR`: Configuration directory (default: "$HOME/.kadmap")
- `GITHUB_REPO`: GitHub repository to download from (default: "kadmap/devtool")

## Troubleshooting

If you encounter issues during installation:

- **Permission denied errors**: The script will attempt to use `sudo` when necessary
- **PATH issues**: You may need to restart your terminal or source your shell configuration file
- **Download failures**: Verify your GitHub token has the correct permissions

## License

This installer is part of the KadMap project and is licensed under the same terms. 