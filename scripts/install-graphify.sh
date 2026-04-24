#!/usr/bin/env bash
# Install graphify for the current user.
# Handles the macOS expat library quirk where graphify's Python XML parser
# can't find expat without DYLD_LIBRARY_PATH.

set -euo pipefail

UNAME=$(uname)

echo "==> Installing graphify..."

if [ "$UNAME" = "Darwin" ]; then
  # macOS
  if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew is required on macOS to install expat. Install from https://brew.sh and re-run."
    exit 1
  fi

  # Ensure expat is present
  if ! brew list expat >/dev/null 2>&1; then
    echo "Installing expat via Homebrew..."
    brew install expat
  fi

  # Prefer Homebrew's python for predictable linkage
  if ! command -v /opt/homebrew/bin/python3.13 >/dev/null 2>&1; then
    echo "Installing python@3.13 via Homebrew..."
    brew install python@3.13
  fi

  # Install pipx if missing
  if ! command -v pipx >/dev/null 2>&1; then
    echo "Installing pipx..."
    brew install pipx
    pipx ensurepath
  fi

  echo "Installing graphifyy via pipx..."
  DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib \
    PIPX_DEFAULT_PYTHON=/opt/homebrew/bin/python3.13 \
    pipx install graphifyy

  # Verify
  if DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib ~/.local/bin/graphify --help >/dev/null 2>&1; then
    echo "==> graphify installed. Remember to prefix calls with DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib on macOS."
  else
    echo "ERROR: graphify install failed. Check the error output above."
    exit 1
  fi

elif [ "$UNAME" = "Linux" ]; then
  # Linux / WSL
  if ! command -v pipx >/dev/null 2>&1; then
    echo "Installing pipx..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y pipx
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y pipx
    else
      echo "ERROR: could not find a supported package manager. Install pipx manually."
      exit 1
    fi
    pipx ensurepath
  fi

  echo "Installing graphifyy..."
  pipx install graphifyy

  if ~/.local/bin/graphify --help >/dev/null 2>&1; then
    echo "==> graphify installed."
  else
    echo "ERROR: graphify install failed."
    exit 1
  fi

else
  echo "ERROR: Unsupported OS: $UNAME. Install graphify manually from https://github.com/graphifyy/graphify"
  exit 1
fi

echo
echo "Done. Next step: return to Claude and continue with SETUP.md step 3."
