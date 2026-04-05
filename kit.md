---
schema: kit/1.0
slug: ghidra-mcp-toolkit
title: Ghidra MCP Toolkit
summary: Give AI agents reverse engineering capabilities — decompile binaries, analyze malware, find vulnerabilities in compiled code, and trace execution flows via Ghidra's MCP bridge.
version: 1.0.0
owner: radicalize
license: MIT
tags:
  - reverse-engineering
  - ghidra
  - mcp
  - binary-analysis
  - malware
  - decompilation
  - disassembly
  - vulnerability-research
  - firmware
  - ctf
tools:
  - ghidra-mcp
skills:
  - binary-analysis
  - malware-triage
  - vulnerability-research
tech:
  - python
  - java
  - mcp
model:
  provider: anthropic
  name: claude-sonnet-4-6
prerequisites:
  - name: java
    check: "java -version"
  - name: python3
    check: "python3 --version"
  - name: git
    check: "git --version"
services:
  - name: Ghidra
    kind: application
    role: NSA reverse engineering framework — decompilation, disassembly, binary analysis
    setup: Download from ghidra-sre.org or GitHub releases. Requires Java 17+.
parameters:
  - name: GHIDRA_REST_PORT
    value: "8080"
    description: Port the GhidraMCP plugin serves REST on
  - name: GHIDRA_INSTALL_DIR
    value: "~/Applications/ghidra"
    description: Ghidra installation directory
failures:
  - problem: "java: command not found"
    resolution: "Install Java 17+. macOS: brew install --cask temurin. Linux: apt install openjdk-17-jdk"
  - problem: "Ghidra won't start — 'Java 17+ required'"
    resolution: "Ensure JAVA_HOME points to JDK 17+. Check: java -version"
  - problem: "GhidraMCP bridge can't connect on port 8080"
    resolution: "GhidraMCP is plain HTTP REST, NOT SSE. You must have a project open in CodeBrowser with GhidraMCPPlugin enabled."
  - problem: "bridge_mcp_ghidra.py import errors"
    resolution: "Install deps in the venv: uv pip install --python ~/ghidra-mcp/.venv requests mcp"
  - problem: "Plugin not visible in Ghidra Configure menu"
    resolution: "Restart Ghidra after installing the extension. The plugin appears under File → Configure → Developer."
  - problem: "uv-managed Python rejects pip install on macOS"
    resolution: "Use 'uv pip install --python /path/to/venv pkg' — uv venvs have no pip binary"
  - problem: "Decompiler returns empty output"
    resolution: "Run auto-analysis first (Analysis → Auto Analyze). The decompiler needs analysis data."
  - problem: "'Address not found' errors"
    resolution: "Use hex addresses with 0x prefix. Check the function list first to get valid addresses."
inputs:
  - name: binary
    description: Path to the binary, firmware image, or executable to analyze
  - name: objective
    description: What you're looking for — malware behavior, vulnerabilities, protocol reverse engineering, CTF flag
outputs:
  - name: analysis
    description: Decompiled code, control flow, identified vulnerabilities, string artifacts
  - name: report
    description: Structured reverse engineering report with findings
useCases:
  - scenario: Malware triage — identify capabilities, C2 infrastructure, persistence mechanisms
  - scenario: Vulnerability research — find buffer overflows, format strings, use-after-free in compiled binaries
  - scenario: Firmware analysis — extract and analyze IoT/embedded device firmware
  - scenario: CTF challenges — solve reverse engineering challenges
  - scenario: Patch diffing — compare two binary versions to identify security fixes
  - scenario: Protocol reverse engineering — understand proprietary network protocols from client binaries
dependencies:
  runtime:
    - Java 17+ (Temurin JDK recommended)
    - Python 3.10+
  cli:
    - java
    - python3
    - git
    - uv (recommended, not required)
selfContained: true
environment:
  os:
    - macOS
    - linux
    - windows
  platforms:
    - claude-code
    - openclaw
    - cursor
    - codex
    - cline
    - windsurf
    - aider
    - generic
fileManifest:
  - path: kit.md
    role: primary
    description: Main workflow guide and setup instructions
  - path: scripts/setup-ghidra.sh
    role: setup
    description: Automated Ghidra + Java + MCP bridge setup
  - path: scripts/healthcheck.sh
    role: verification
    description: Verify Ghidra MCP bridge is reachable
  - path: templates/re-report.md
    role: template
    description: Reverse engineering report template
verification:
  command: "bash scripts/healthcheck.sh"
  expected: "Ghidra MCP healthy"
---

# Ghidra MCP Toolkit

Give any AI coding agent the ability to reverse engineer binaries. The agent can decompile functions, trace cross-references, extract strings, analyze control flow, and navigate complex binaries — all through Ghidra's MCP bridge.

Ghidra is the NSA's open-source reverse engineering framework. This kit wires it into your agent via MCP so you can have conversations like:

```
"Decompile main() and tell me what this binary does"
"Find all functions that reference the string 'password'"
"Trace the call chain from recv() to see how network input is processed"
"Look for buffer overflow vulnerabilities in the input parsing functions"
```

## Architecture

```
Your Agent (Claude Code / Cursor / Codex / OpenClaw / etc.)
    ↓ MCP stdio
┌──────────────────────────────────────────────────────┐
│  ghidra-mcp       Ghidra REST API bridge (port 8080) │
│  ├─ decompile     Decompile function → C pseudocode  │
│  ├─ disassemble   Get assembly listing               │
│  ├─ functions     List/search all functions           │
│  ├─ xrefs_to      Cross-references TO an address     │
│  ├─ xrefs_from    Cross-references FROM an address    │
│  ├─ strings       Extract all strings in binary       │
│  ├─ search_bytes  Search for byte patterns            │
│  ├─ data_types    List defined data types/structs     │
│  ├─ segments      List memory segments/sections       │
│  ├─ imports       List imported functions              │
│  ├─ exports       List exported symbols               │
│  ├─ rename        Rename functions/variables           │
│  ├─ comment       Add comments to addresses            │
│  ├─ analyze       Trigger auto-analysis               │
│  └─ memory_read   Read raw bytes at address           │
└──────────────────────────────────────────────────────┘
    ↕ HTTP REST (localhost:8080)
┌──────────────────────────────────────────────────────┐
│  Ghidra (CodeBrowser)                                │
│  GhidraMCPPlugin enabled                             │
│  Binary loaded and analyzed                          │
└──────────────────────────────────────────────────────┘
```

**Important:** GhidraMCP serves plain HTTP REST on port 8080. It is NOT an SSE server. Do not use mcp-proxy or SSE transport — use the FastMCP stdio bridge (`bridge_mcp_ghidra.py`).

## Full Setup

### One-Shot Install

```bash
bash scripts/setup-ghidra.sh
```

This installs Java (if needed), downloads Ghidra, clones the MCP bridge, creates the Python venv, and creates a macOS .app wrapper.

### Manual Setup

#### Step 1 — Install Java 17+

Ghidra requires Java 17 or later.

**macOS:**
```bash
brew install --cask temurin

# Verify
java -version
# openjdk version "17.x.x" or higher
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install -y openjdk-17-jdk

# Verify
java -version
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install -y java-17-openjdk-devel
```

**Windows:**
Download Temurin JDK 17 from https://adoptium.net/temurin/releases/

#### Step 2 — Install Ghidra

**All platforms:**
```bash
# Download latest release
# https://github.com/NationalSecurityAgency/ghidra/releases

# macOS/Linux — extract to home directory
cd ~/Applications  # or ~/ghidra
unzip ghidra_*_PUBLIC_*.zip

# Verify it starts
~/Applications/ghidra_*/ghidraRun
```

**macOS — optional .app wrapper for Spotlight/Dock:**
```bash
mkdir -p /Applications/Ghidra.app/Contents/MacOS
cat > /Applications/Ghidra.app/Contents/MacOS/Ghidra << 'WRAPPER'
#!/bin/bash
exec "$HOME/Applications/ghidra_"*/ghidraRun "$@"
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
```

#### Step 3 — Install GhidraMCP Plugin

```bash
# Download GhidraMCP from GitHub
# https://github.com/LaurieWired/GhidraMCP/releases

# Clone for the bridge script
git clone https://github.com/LaurieWired/GhidraMCP.git ~/ghidra-mcp

# In Ghidra (GUI — 5 clicks):
# 1. File → Install Extensions
# 2. Click green + button
# 3. Select the GhidraMCP-*.zip from the release
# 4. Restart Ghidra when prompted
# 5. Open a project in CodeBrowser, then:
#    File → Configure → Developer → check GhidraMCPPlugin → Apply
```

#### Step 4 — MCP Bridge Setup

```bash
cd ~/ghidra-mcp

# macOS (uv — recommended):
uv venv ~/ghidra-mcp/.venv --python 3.11
uv pip install --python ~/ghidra-mcp/.venv requests mcp

# Linux / standard pip:
python3 -m venv ~/ghidra-mcp/.venv
~/ghidra-mcp/.venv/bin/pip install requests mcp

# Verify bridge can start (will fail to connect if Ghidra isn't open — that's OK)
~/ghidra-mcp/.venv/bin/python3 ~/ghidra-mcp/bridge_mcp_ghidra.py --help 2>/dev/null || echo "Bridge installed"
```

#### Step 5 — Agent Configuration

**Claude Code** — add to `~/.claude/mcp.json`:
```json
{
  "mcpServers": {
    "ghidra": {
      "command": "HOMEDIR/ghidra-mcp/.venv/bin/python3",
      "args": ["HOMEDIR/ghidra-mcp/bridge_mcp_ghidra.py"]
    }
  }
}
```

**OpenClaw / Hermes** — add to config:
```yaml
mcp_servers:
  ghidra:
    command: "~/ghidra-mcp/.venv/bin/python3"
    args: ["~/ghidra-mcp/bridge_mcp_ghidra.py"]
    timeout: 180
    connect_timeout: 30
```

**Cursor** — add to `.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "ghidra": {
      "command": "HOMEDIR/ghidra-mcp/.venv/bin/python3",
      "args": ["HOMEDIR/ghidra-mcp/bridge_mcp_ghidra.py"]
    }
  }
}
```

Replace `HOMEDIR` with your actual home directory path.

## Workflows

### Malware Triage

```
1. "Import this binary into Ghidra and run auto-analysis"
2. "List all imported functions — look for network, crypto, and file system APIs"
3. "Extract all strings and flag anything that looks like URLs, IPs, or C2 domains"
4. "Decompile the function that calls connect() — trace how the C2 address is built"
5. "Find all functions that reference CreateRemoteThread or WriteProcessMemory"
6. "Check for anti-debug techniques — look for IsDebuggerPresent, NtQueryInformationProcess"
7. "Map the malware's capabilities: persistence, exfiltration, lateral movement"
```

### Vulnerability Research

```
1. "List all functions that take user input — recv, read, fgets, scanf"
2. "Decompile each input handler and look for buffer overflows"
3. "Check if there's bounds checking before memcpy/strcpy calls"
4. "Trace the data flow from recv() through parsing to where it's used"
5. "Look for format string vulnerabilities — printf with user-controlled format"
6. "Check for integer overflow in size calculations before malloc"
7. "Find any use-after-free patterns — free() followed by dereference"
```

### Firmware Analysis

```
1. "Identify the architecture and base address from the binary headers"
2. "List all strings — look for default credentials, debug interfaces, API keys"
3. "Find the main loop and trace command handling"
4. "Look for update mechanisms — are firmware updates signed?"
5. "Check for hardcoded crypto keys or certificates"
6. "Map the UART/serial console handler if present"
```

### CTF Reverse Engineering

```
1. "Decompile main() — what does this binary expect as input?"
2. "Find the flag check function — what's it comparing against?"
3. "Trace the transformation applied to user input before comparison"
4. "Extract the expected values and work backwards to find the flag"
5. "Check for anti-tampering — does it detect debuggers or patching?"
```

### Patch Diffing

```
1. "I have two versions of this binary — before and after the security patch"
2. "Compare the function lists — which functions were added or modified?"
3. "Decompile the changed functions in both versions side by side"
4. "Identify what vulnerability the patch fixes based on the code changes"
```

## MCP Tool Reference

| Tool | Description | Example |
|------|-------------|---------|
| `ghidra_functions` | List all functions with addresses | Find entry points |
| `ghidra_decompile` | Decompile function → C pseudocode | `decompile main` or `decompile 0x401000` |
| `ghidra_disassemble` | Get assembly listing | Low-level analysis |
| `ghidra_xrefs_to` | What calls/references this address | Trace callers |
| `ghidra_xrefs_from` | What this function calls/references | Trace callees |
| `ghidra_strings` | Extract all strings in binary | Find URLs, creds, keys |
| `ghidra_imports` | List imported functions (DLL/SO) | Identify capabilities |
| `ghidra_exports` | List exported symbols | Find API surface |
| `ghidra_segments` | List memory segments (.text, .data, etc.) | Understand layout |
| `ghidra_search_bytes` | Search for byte patterns | Find crypto constants |
| `ghidra_data_types` | List defined structs/types | Understand data structures |
| `ghidra_rename` | Rename function or variable | Clean up analysis |
| `ghidra_comment` | Add comment at address | Document findings |
| `ghidra_analyze` | Trigger auto-analysis | Initial analysis pass |
| `ghidra_memory_read` | Read raw bytes at address | Extract embedded data |

## Effective Agent Prompting Tips

**Be specific with addresses.** Instead of "decompile that function", say "decompile the function at 0x401230" or "decompile the function named `process_input`".

**Start broad, go deep.** Begin with `functions` and `strings` to orient, then drill into specific functions with `decompile` and `xrefs`.

**Name things as you go.** Use `rename` to give meaningful names to functions and variables. This makes subsequent decompilation output much more readable.

**Cross-reference is your best friend.** `xrefs_to` answers "who calls this?" and `xrefs_from` answers "what does this call?". Together they map the call graph.

**Run analysis first.** If decompilation looks wrong or incomplete, run `analyze` to trigger Ghidra's auto-analysis. Many features depend on analysis data.

## Pitfalls

1. **Ghidra must have an open project in CodeBrowser** — the MCP plugin only works when CodeBrowser is active with a loaded binary
2. **GhidraMCP is plain HTTP REST** — do NOT use mcp-proxy or SSE transport
3. **Java 17+ required** — Ghidra won't start without it
4. **Run auto-analysis before decompiling** — the decompiler needs analysis data
5. **macOS uv venvs have no pip** — use `uv pip install --python path pkg`
6. **Plugin install requires Ghidra restart** — it won't appear until you restart
7. **Large binaries take time** — auto-analysis on a 50MB+ binary can take minutes
8. **Address format** — use hex with 0x prefix (e.g. `0x401000`), not decimal
