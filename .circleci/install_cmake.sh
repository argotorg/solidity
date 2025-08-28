#!/bin/bash
# Usage: ./install_cmake.sh 3.28.3
# Installs a specific CMake version on macOS from Kitware releases.
# Layout:
#   /usr/local/cmake-<version>/CMake.app/Contents/bin/{cmake,ccmake,cpack,ctest}
# Symlinks:
#   /usr/local/bin/{cmake,ccmake,cpack,ctest} -> .../Contents/bin/<tool>
# Works on both Intel and Apple Silicon (uses "macos-universal" tarball).

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <cmake-version>"
  exit 1
fi

VERSION="$1"
INSTALL_DIR="/usr/local/cmake-$VERSION"
TARBALL="cmake-$VERSION-macos-universal.tar.gz"
URL="https://github.com/Kitware/CMake/releases/download/v$VERSION/$TARBALL"
TMPFILE="/tmp/$TARBALL"

# Require basic tools
for cmd in curl tar; do
  command -v "$cmd" >/dev/null || { echo "Missing $cmd"; exit 1; }
done

# Skip if already installed
if [ -d "$INSTALL_DIR" ] && [ -x "$INSTALL_DIR/CMake.app/Contents/bin/cmake" ]; then
  echo "CMake $VERSION already installed at $INSTALL_DIR"
else
  echo "Downloading $URL ..."
  # --fail makes curl exit non-zero on 404/5xx; -L follows redirects
  curl -fL "$URL" -o "$TMPFILE"

  echo "Creating $INSTALL_DIR and extracting..."
  sudo mkdir -p "$INSTALL_DIR"

  # The tarball contains a top-level directory (e.g., cmake-<ver>-macos-universal/*)
  # We strip that first component so CMake.app ends up directly under $INSTALL_DIR.
  sudo tar -xzf "$TMPFILE" -C "$INSTALL_DIR" --strip-components=1

  # Work around Gatekeeper quarantine if present (harmless if attribute absent)
  if command -v xattr >/dev/null; then
    sudo xattr -dr com.apple.quarantine "$INSTALL_DIR/CMake.app" || true
  fi

  # Sanity check
  if [ ! -x "$INSTALL_DIR/CMake.app/Contents/bin/cmake" ]; then
    echo "Error: cmake binary not found under $INSTALL_DIR/CMake.app/Contents/bin"
    exit 1
  fi
fi

echo "Linking command-line tools into /usr/local/bin ..."
for tool in cmake ccmake cpack ctest; do
  sudo ln -sfn "$INSTALL_DIR/CMake.app/Contents/bin/$tool" "/usr/local/bin/$tool"
done

# Optional: link cmake-gui (will open the GUI app)
if [ -x "$INSTALL_DIR/CMake.app/Contents/bin/cmake-gui" ]; then
  sudo ln -sfn "$INSTALL_DIR/CMake.app/Contents/bin/cmake-gui" /usr/local/bin/cmake-gui
fi

echo "CMake $VERSION installed successfully."
which cmake
cmake --version
