#!/usr/bin/env bash
# =========================================================
# OpenSSL Tech Debt Observatory - Compile Commands Builder
# Author: Basil Addington
# Purpose: Clean, configure, and build OpenSSL 3.x/4.x
#          with `bear` to generate a compile_commands.json
#          suitable for clangd and clang-tidy analysis.
# Notes:
#   - Can be run from tools/ directory.
#   - Prints detailed screen output.
#   - Supports Intel (x86_64) and Apple Silicon (arm64) macOS.
#   - AI Generated chatgpt
# =========================================================

set -e
set -o pipefail

# -----------------------------
# CONFIGURATION
# -----------------------------

# Absolute path to OpenSSL repo
OPENSSL_DIR="/Users/basiladdington/Projects/tech-debt-showcase/local-repos/openssl"

# Number of CPU cores for parallel build
CORES=$(sysctl -n hw.ncpu)

# -----------------------------
# START SCRIPT
# -----------------------------
echo "=================================================="
echo "[INFO] OpenSSL Tech Debt Observatory - Build Script"
echo "[INFO] OpenSSL repo: $OPENSSL_DIR"
echo "[INFO] Using $CORES CPU cores for build"
echo "=================================================="

# -----------------------------
# Verify OpenSSL directory exists
# -----------------------------
if [[ ! -d "$OPENSSL_DIR" ]]; then
    echo "[ERROR] OpenSSL directory not found: $OPENSSL_DIR"
    exit 1
fi

# -----------------------------
# Detect platform
# -----------------------------
ARCH=$(uname -m)
OS=$(uname)
echo "[INFO] Detected platform: $OS $ARCH"

if [[ "$OS" != "Darwin" ]]; then
    echo "[ERROR] Unsupported OS: $OS"
    exit 1
fi

# Determine correct Configure target
if [[ "$ARCH" == "x86_64" ]]; then
    TARGET="darwin64-x86_64-cc"
elif [[ "$ARCH" == "arm64" ]]; then
    TARGET="darwin64-arm64-cc"
else
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
fi
echo "[INFO] Configure target: $TARGET"

# -----------------------------
# Move into OpenSSL directory
# -----------------------------
cd "$OPENSSL_DIR"
echo "[INFO] Entered OpenSSL directory: $(pwd)"

# -----------------------------
# Clean previous build
# -----------------------------
echo "[INFO] Cleaning previous build artifacts..."
make clean || true
rm -f compile_commands.json

# -----------------------------
# Configure OpenSSL
# -----------------------------
echo "[INFO] Running Configure..."
./Configure $TARGET no-shared || { echo "[ERROR] Configure failed"; exit 1; }

# -----------------------------
# Build with bear
# -----------------------------
echo "[INFO] Building OpenSSL with bear to generate compile_commands.json..."
bear -- make -j"$CORES" || { echo "[ERROR] Build failed"; exit 1; }

# -----------------------------
# Verify compile_commands.json
# -----------------------------
if [[ -f compile_commands.json ]]; then
    echo "[INFO] Success! compile_commands.json created in OpenSSL root."
    echo "[INFO] Sample entries:"
    head -n 15 compile_commands.json
else
    echo "[ERROR] compile_commands.json not found!"
    exit 1
fi

echo "=================================================="
echo "[INFO] OpenSSL Tech Debt Observatory setup complete."
echo "[INFO] You can now open VSCode/VSCodium and clangd will use compile_commands.json"
echo "=================================================="
