#!/bin/bash
set -e
echo "=== Ghidra MCP Toolkit Setup ==="

# Check Java
if ! command -v java &>/dev/null; then
  echo "Java 17+ required. Installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      brew install --cask temurin
    else
      echo "ERROR: Install Homebrew first (https://brew.sh) or install Java manually"
      echo "  Download Temurin JDK 17: https://adoptium.net/temurin/releases/"
      exit 1
    fi
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y openjdk-17-jdk
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y java-17-openjdk-devel
  else
    echo "ERROR: Install Java 17+ manually: https://adoptium.net/temurin/releases/"
    exit 1
  fi
fi

JAVA_VER=$(java -version 2>&1 | head -1 | grep -oE '[0-9]+' | head -1)
echo "Java version: $JAVA_VER"
if [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
  echo "WARNING: Java $JAVA_VER detected. Ghidra needs 17+."
fi

# Check for Ghidra installation
GHIDRA_DIR=$(find ~/Applications ~/ghidra /opt/ghidra -maxdepth 1 -name "ghidra_*" -type d 2>/dev/null | head -1)
if [ -z "$GHIDRA_DIR" ]; then
  echo ""
  echo "Ghidra not found. Download from:"
  echo "  https://github.com/NationalSecurityAgency/ghidra/releases"
  echo ""
  echo "Extract to ~/Applications/ and re-run this script."
  echo ""
  
  # Offer to download on macOS/Linux
  read -p "Download latest Ghidra now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Fetching latest release URL..."
    GHIDRA_URL=$(curl -s https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest | grep "browser_download_url.*zip" | head -1 | cut -d'"' -f4)
    if [ -n "$GHIDRA_URL" ]; then
      mkdir -p ~/Applications
      echo "Downloading $(basename $GHIDRA_URL)..."
      curl -L -o "/tmp/ghidra-latest.zip" "$GHIDRA_URL"
      echo "Extracting to ~/Applications..."
      unzip -q "/tmp/ghidra-latest.zip" -d ~/Applications/
      rm /tmp/ghidra-latest.zip
      GHIDRA_DIR=$(find ~/Applications -maxdepth 1 -name "ghidra_*" -type d | head -1)
      echo "Ghidra installed at: $GHIDRA_DIR"
    else
      echo "ERROR: Couldn't find download URL. Install manually."
      exit 1
    fi
  else
    exit 1
  fi
else
  echo "Found Ghidra at: $GHIDRA_DIR"
fi

# macOS .app wrapper
if [[ "$OSTYPE" == "darwin"* ]] && [ ! -d "/Applications/Ghidra.app" ]; then
  echo "Creating macOS .app wrapper..."
  mkdir -p /Applications/Ghidra.app/Contents/MacOS
  cat > /Applications/Ghidra.app/Contents/MacOS/Ghidra << WRAPPER
#!/bin/bash
exec "$GHIDRA_DIR/ghidraRun" "\$@"
WRAPPER
  chmod +x /Applications/Ghidra.app/Contents/MacOS/Ghidra
  cat > /Applications/Ghidra.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>Ghidra</string>
<key>CFBundleIdentifier</key><string>org.ghidra.re</string>
<key>CFBundleName</key><string>Ghidra</string>
<key>CFBundlePackageType</key><string>APPL</string>
</dict></plist>
PLIST
  echo "✓ Ghidra.app wrapper created"
fi

# Clone GhidraMCP
if [ ! -d "$HOME/ghidra-mcp" ]; then
  echo "Cloning GhidraMCP bridge..."
  git clone https://github.com/LaurieWired/GhidraMCP.git "$HOME/ghidra-mcp"
fi

# Python venv for MCP bridge
cd "$HOME/ghidra-mcp"
if command -v uv &>/dev/null; then
  echo "Setting up venv with uv..."
  uv venv "$HOME/ghidra-mcp/.venv" --python 3.11 2>/dev/null || uv venv "$HOME/ghidra-mcp/.venv"
  uv pip install --python "$HOME/ghidra-mcp/.venv" requests mcp
else
  echo "Setting up venv with python3..."
  python3 -m venv "$HOME/ghidra-mcp/.venv"
  "$HOME/ghidra-mcp/.venv/bin/pip" install requests mcp
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "✓ Java $(java -version 2>&1 | head -1)"
echo "✓ Ghidra at: $GHIDRA_DIR"
echo "✓ MCP bridge at: ~/ghidra-mcp"
echo "✓ Python venv at: ~/ghidra-mcp/.venv"
echo ""
echo "Next steps (one-time, in Ghidra GUI):"
echo "  1. Download GhidraMCP plugin: https://github.com/LaurieWired/GhidraMCP/releases"
echo "  2. In Ghidra: File → Install Extensions → + → select the .zip"
echo "  3. Restart Ghidra"
echo "  4. Open a project in CodeBrowser"
echo "  5. File → Configure → Developer → check GhidraMCPPlugin → Apply"
echo ""
echo "Then configure your agent's MCP settings (see kit.md for configs)."
