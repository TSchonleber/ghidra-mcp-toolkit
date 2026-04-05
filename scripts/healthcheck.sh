#!/bin/bash
echo "=== Ghidra MCP Health Check ==="

# Check Java
if command -v java &>/dev/null; then
  JAVA_VER=$(java -version 2>&1 | head -1)
  echo "✓ Java: $JAVA_VER"
else
  echo "✗ Java: not found (required for Ghidra)"
fi

# Check Ghidra install
GHIDRA_DIR=$(find ~/Applications ~/ghidra /opt/ghidra -maxdepth 1 -name "ghidra_*" -type d 2>/dev/null | head -1)
if [ -n "$GHIDRA_DIR" ]; then
  echo "✓ Ghidra: $GHIDRA_DIR"
else
  echo "✗ Ghidra: not found"
fi

# Check bridge venv
if [ -f "$HOME/ghidra-mcp/.venv/bin/python3" ]; then
  echo "✓ Bridge venv: ~/ghidra-mcp/.venv"
else
  echo "✗ Bridge venv: not found at ~/ghidra-mcp/.venv"
fi

# Check Ghidra REST API
if curl -sf http://127.0.0.1:8080/ >/dev/null 2>&1; then
  echo "✓ Ghidra MCP: healthy (port 8080)"
  echo ""
  echo "Ghidra MCP healthy"
else
  echo "- Ghidra MCP: not reachable (port 8080)"
  echo "  This is expected if Ghidra isn't open with a project in CodeBrowser."
  echo "  Open Ghidra → CodeBrowser → enable GhidraMCPPlugin to activate."
fi
