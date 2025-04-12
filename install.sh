#!/usr/bin/env bash

set -e

# Configuration
CLI_NAME="kadmap"
CLI_VERSION="${VERSION:-latest}"  # Use VERSION env var if set, otherwise use 'latest'
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.kadmap"
GITHUB_REPO="kadmap/kadkit"
# Fallback token if GitHub CLI is not available (replace with your token)
GITHUB_TOKEN="${GITHUB_TOKEN:-""}"

# Print step information
print_step() {
  echo "===> $1"
}

# Check if GitHub CLI is available and authenticated
check_github_cli() {
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null; then
      return 0  # GitHub CLI is available and authenticated
    fi
  fi
  return 1  # GitHub CLI is not available or not authenticated
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

# Download with GitHub CLI
download_with_gh_cli() {
  local PLATFORM=$1
  local OUTPUT_DIR=$2
  local VERSION=$3
  local REPO=$4
  
  print_step "Using GitHub CLI to download release"
  
  # For latest release
  if [ "$VERSION" = "latest" ]; then
    gh release download --repo "$REPO" --pattern "*$PLATFORM.tar.gz" --dir "$OUTPUT_DIR"
  else
    # For specific version
    gh release download "$VERSION" --repo "$REPO" --pattern "*$PLATFORM.tar.gz" --dir "$OUTPUT_DIR"
  fi
  
  # Extract the downloaded archive
  tar xzf "$OUTPUT_DIR"/*"$PLATFORM.tar.gz" -C "$OUTPUT_DIR"
  
  # Remove the archive file after extraction
  rm "$OUTPUT_DIR"/*"$PLATFORM.tar.gz"
}

# Download with curl and token
download_with_token() {
  local PLATFORM=$1
  local OUTPUT_DIR=$2
  local VERSION=$3
  local REPO=$4
  local TOKEN=$5
  
  print_step "Using personal access token to download release"
  
  local API_URL
  if [ "$VERSION" = "latest" ]; then
    API_URL="https://api.github.com/repos/$REPO/releases/latest"
  else
    API_URL="https://api.github.com/repos/$REPO/releases/tags/$VERSION"
  fi
  
  # Get the asset download URL with token authentication
  local ASSET_URL
  ASSET_URL=$(curl -s -H "Authorization: token $TOKEN" $API_URL | 
    grep -o "https://.*$CLI_NAME-$PLATFORM.tar.gz" | 
    head -n 1)
  
  if [ -z "$ASSET_URL" ]; then
    echo "Error: Could not find release asset for platform $PLATFORM" >&2
    exit 1
  fi
  
  print_step "Downloading from $ASSET_URL"
  
  # Download and extract with authentication
  curl -sL -H "Authorization: token $TOKEN" -H "Accept: application/octet-stream" \
    "$ASSET_URL" | tar xz -C "$OUTPUT_DIR"
}

# Install the CLI tool
install_cli() {
  local PLATFORM=$1
  local TMP_DIR
  TMP_DIR=$(mktemp -d)
  
  print_step "Downloading $CLI_NAME ($CLI_VERSION) for $PLATFORM"
  
  # Try GitHub CLI first, fall back to token if needed
  if check_github_cli; then
    download_with_gh_cli "$PLATFORM" "$TMP_DIR" "$CLI_VERSION" "$GITHUB_REPO" || {
      if [ -n "$GITHUB_TOKEN" ]; then
        download_with_token "$PLATFORM" "$TMP_DIR" "$CLI_VERSION" "$GITHUB_REPO" "$GITHUB_TOKEN"
      else
        echo "Error: GitHub CLI download failed and no token provided."
        echo "Please either install and authenticate GitHub CLI or set GITHUB_TOKEN env variable."
        exit 1
      fi
    }
  else
    if [ -n "$GITHUB_TOKEN" ]; then
      download_with_token "$PLATFORM" "$TMP_DIR" "$CLI_VERSION" "$GITHUB_REPO" "$GITHUB_TOKEN"
    else
      echo "Error: GitHub CLI not available and no token provided."
      echo "Please either:"
      echo "1. Install GitHub CLI and authenticate with 'gh auth login'"
      echo "2. Set GITHUB_TOKEN environment variable with a valid token"
      echo "3. Edit this script to include your token"
      exit 1
    fi
  fi
  
  # Directory where the extracted content is located
  local EXTRACT_DIR="$TMP_DIR/$CLI_NAME-$PLATFORM"
  
  print_step "Installing $CLI_NAME to $INSTALL_DIR"
  
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
