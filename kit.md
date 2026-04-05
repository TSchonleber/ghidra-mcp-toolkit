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

## Goal

Give any AI coding agent reverse engineering capabilities — decompile binaries to C pseudocode, trace cross-references, extract strings, analyze control flow, and navigate complex compiled code — all through Ghidra's MCP bridge.

## When to Use

- Analyzing compiled binaries to understand their behavior
- Firmware analysis for IoT and embedded devices
- Security research on compiled applications
- CTF (Capture The Flag) reverse engineering challenges
- Comparing binary versions to identify code changes (patch diffing)
- Understanding proprietary protocols from client binaries

## Setup

### Models

Any model that supports MCP tool calls. Verified with claude-sonnet-4-6. Model-agnostic.

### Services

| Service | Purpose | Install |
|---------|---------|---------|
| Java 17+ | Required runtime for Ghidra | `brew install --cask temurin` (macOS) or `apt install openjdk-17-jdk` (Linux) |
| Ghidra | NSA reverse engineering framework | Download from github.com/NationalSecurityAgency/ghidra/releases |

### Environment

Works on macOS, Linux, and Windows. The setup script handles Java detection, Ghidra download, MCP bridge installation, and macOS .app wrapper creation.

### Quick Install

```bash
bash scripts/setup-ghidra.sh
bash scripts/healthcheck.sh
```

### Agent Configuration

Add the Ghidra MCP server to your agent config. Example for Claude Code (`~/.claude/mcp.json`):

```json
{
  "mcpServers": {
    "ghidra": {
      "command": "~/ghidra-mcp/.venv/bin/python3",
      "args": ["~/ghidra-mcp/bridge_mcp_ghidra.py"]
    }
  }
}
```

**Important:** GhidraMCP serves plain HTTP REST on port 8080. It is NOT an SSE server. Use the FastMCP stdio bridge, not mcp-proxy.

### One-Time Ghidra Plugin Setup (5 clicks)

1. Open Ghidra → File → Install Extensions → click + button
2. Select the GhidraMCP .zip from the release
3. Restart Ghidra when prompted
4. Open a project in CodeBrowser
5. File → Configure → Developer → check GhidraMCPPlugin → Apply

## Steps

### 1. Orient

List all functions and extract strings to understand the binary's purpose.

```
"List all functions in this binary. Extract all strings and flag anything interesting — URLs, file paths, error messages, format strings."
```

### 2. Identify Key Functions

Find entry points and important code paths by tracing imports and cross-references.

```
"List imported functions. Find all functions that reference network or file I/O APIs. Show the cross-references."
```

### 3. Decompile and Analyze

Read the decompiled C pseudocode for functions of interest.

```
"Decompile the function at 0x401230. Explain what it does and trace its data flow."
```

### 4. Map Behavior

Build a picture of the binary's capabilities by following call chains.

```
"Trace the call chain from the main entry point. Map what each major function does."
```

### 5. Document

Clean up the analysis with meaningful names and comments. Generate a report.

```
"Rename the discovered functions with meaningful names. Add comments at key addresses. Generate an analysis report."
```

## Failures Overcome

| Problem | Resolution |
|---------|-----------|
| GhidraMCP bridge can't connect on port 8080 | Must have a project open in CodeBrowser with GhidraMCPPlugin enabled |
| Java not found | Install JDK 17+: brew install --cask temurin (macOS) or apt install openjdk-17-jdk (Linux) |
| uv-managed Python rejects pip on macOS | Use `uv pip install --python /path/to/venv pkg` |
| Decompiler returns empty output | Run auto-analysis first: Analysis → Auto Analyze |
| Address not found errors | Use hex with 0x prefix. Check function list for valid addresses. |

## Constraints

- Ghidra must have an open project in CodeBrowser with GhidraMCPPlugin enabled
- GhidraMCP is plain HTTP REST — do NOT use mcp-proxy or SSE transport
- Java 17+ required — Ghidra won't start without it
- Large binaries (50MB+) take minutes for auto-analysis
- Use hex addresses with 0x prefix

## Safety Notes

Reverse engineering is legal in most jurisdictions for security research, interoperability, and education. However:

- Respect software license agreements and local laws
- Do not distribute proprietary decompiled code
- Follow responsible disclosure for any vulnerabilities discovered
- CTF challenges and open-source binaries are always safe targets

## Validation

```bash
bash scripts/healthcheck.sh
```

Expected: "Ghidra MCP healthy" (requires Ghidra open with a loaded project)
