#!/usr/bin/env bash

set -e

# Configuration
CLI_NAME="kadmap"
CLI_VERSION="${VERSION:-latest}"  # Use VERSION env var if set, otherwise use 'latest'
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.kadmap"
GITHUB_REPO="kadmap/devtool"

# Print step information
print_step() {
  echo "===> $1"
}

# Detect the operating system and architecture
detect_platform() {
  local OS
  local ARCH
  
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  
  # Convert architecture names
  case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm" ;;
  esac
  
  echo "${OS}_${ARCH}"
}

# Check for required tools
check_dependencies() {
  local REQUIRED_TOOLS=("curl" "tar" "gzip")
  
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Error: Required tool '$tool' is not installed." >&2
      echo "Please install it and try again." >&2
      exit 1
    fi
  done
}

# Install the CLI tool
install_cli() {
  local PLATFORM=$1
  local TMP_DIR
  TMP_DIR=$(mktemp -d)
  
  print_step "Downloading $CLI_NAME ($CLI_VERSION) for $PLATFORM"
  
  # Download the archive
  local GITHUB_TOKEN="your_personal_access_token"
  local DOWNLOAD_URL="https://api.github.com/repos/$GITHUB_REPO/releases/tags/$CLI_VERSION"
  
  # Get the asset download URL
  asset_url=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $DOWNLOAD_URL | 
    grep -o "https://.*$CLI_NAME-$PLATFORM.tar.gz" | 
    head -n 1)
  
  print_step "Downloading from $asset_url"
  
  # Download and extract with authentication
  curl -sL -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/octet-stream" \
    "$asset_url" | tar xz -C "$TMP_DIR"
  
  # Directory where the extracted content is located
  local EXTRACT_DIR="$TMP_DIR/$CLI_NAME-$PLATFORM"
  
  print_step "Installing $CLI_NAME to $INSTALL_DIdR"
  
  # Ensure install directory exists and is writable
  if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR" || sudo mkdir -p "$INSTALL_DIR"
  fi
  
  # Move binary to install directory
  if [ -w "$INSTALL_DIR" ]; then
    mv "$EXTRACT_DIR/$CLI_NAME"* "$INSTALL_DIR/$CLI_NAME"
  else
    sudo mv "$EXTRACT_DIR/$CLI_NAME"* "$INSTALL_DIR/$CLI_NAME"
  fi
  
  # Make binary executable
  if [ -w "$INSTALL_DIR/$CLI_NAME" ]; then
    chmod +x "$INSTALL_DIR/$CLI_NAME"
  else
    sudo chmod +x "$INSTALL_DIR/$CLI_NAME"
  fi
  
  print_step "Installing configuration templates to $CONFIG_DIR"
  
  # Create config directory if it doesn't exist
  mkdir -p "$CONFIG_DIR"
  
  # Copy configuration templates
  if [ -d "$EXTRACT_DIR/.kadmap" ]; then
    cp -r "$EXTRACT_DIR/.kadmap/"* "$CONFIG_DIR/"
    echo "Configuration templates installed to $CONFIG_DIR"
  else
    echo "Warning: Configuration templates not found in the archive."
  fi
  
  # Clean up
  rm -rf "$TMP_DIR"
}

# Verify the installation
verify_installation() {
  if command -v "$CLI_NAME" >/dev/null 2>&1; then
    print_step "Successfully installed $CLI_NAME!"
    echo
    echo "To use it, run: $CLI_NAME --help"
    echo "Configuration templates are located at: $CONFIG_DIR"
    return 0
  else
    echo "Error: Installation failed. $CLI_NAME is not in your PATH." >&2
    echo "You might need to add $INSTALL_DIR to your PATH or restart your terminal." >&2
    return 1
  fi
}

# Update PATH if needed
update_path() {
  # Check if INSTALL_DIR is in PATH
  if ! echo "$PATH" | tr ':' '\n' | grep -q "^$INSTALL_DIR$"; then
    print_step "Adding $INSTALL_DIR to PATH"
    
    # Detect shell
    local SHELL_RC
    if [ -n "$ZSH_VERSION" ]; then
      SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
      SHELL_RC="$HOME/.bashrc"
    else
      echo "Warning: Unknown shell. You may need to manually add $INSTALL_DIR to your PATH."
      return
    fi
    
    # Add to shell configuration
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    echo "Added $INSTALL_DIR to PATH in $SHELL_RC"
    echo "Please restart your terminal or run 'source $SHELL_RC' to apply changes."
  fi
}

# Main function to run the installation
main() {
  print_step "Installing $CLI_NAME"
  
  check_dependencies
  local PLATFORM
  PLATFORM=$(detect_platform)
  OS=${PLATFORM%_*}  # Extract OS part for later use
  install_cli "$PLATFORM"
  update_path
  verify_installation
  
  echo
  echo "Thank you for installing $CLI_NAME!"
}

# Run the main function
main
