---
name: ghidra-analysis
description: "Reverse engineer binaries using Ghidra MCP tools — decompile functions, trace cross-references, extract strings, analyze control flow, and document findings."
version: 1.0.0
tags: [reverse-engineering, ghidra, binary-analysis, decompilation, mcp]
trigger: "When the user asks to analyze a binary, decompile code, reverse engineer a program, examine firmware, or solve a CTF challenge."
---

# Ghidra Analysis

## Prerequisites

- Ghidra open with a binary loaded in CodeBrowser
- GhidraMCPPlugin enabled (File → Configure → Developer → check it)
- MCP bridge running (the agent config handles this automatically)
- Java 17+ installed

## Available MCP Tools

- `ghidra_functions` — List all functions with addresses and sizes
- `ghidra_decompile` — Decompile a function to C pseudocode (by name or address)
- `ghidra_disassemble` — Get assembly listing for an address range
- `ghidra_xrefs_to` — What calls or references this address (trace callers)
- `ghidra_xrefs_from` — What this function calls or references (trace callees)
- `ghidra_strings` — Extract all strings in the binary
- `ghidra_imports` — List imported functions (DLL/SO dependencies)
- `ghidra_exports` — List exported symbols (API surface)
- `ghidra_segments` — List memory segments (.text, .data, .bss, etc.)
- `ghidra_search_bytes` — Search for byte patterns (crypto constants, magic numbers)
- `ghidra_data_types` — List defined structs and data types
- `ghidra_rename` — Rename functions or variables for clarity
- `ghidra_comment` — Add comments at addresses to document findings
- `ghidra_analyze` — Trigger Ghidra's auto-analysis pass
- `ghidra_memory_read` — Read raw bytes at an address

## Workflow

### Step 1: Orient
Start broad. Get the lay of the land before diving into specifics.

```
ghidra_functions    → How many functions? What are the entry points?
ghidra_strings      → URLs, IPs, error messages, format strings, credentials?
ghidra_imports      → What APIs does it use? Network? File? Crypto? Process?
ghidra_segments     → What sections exist? How big is each?
```

### Step 2: Identify Targets
Use imports and strings to find interesting functions.

```
ghidra_xrefs_to <address>   → Who calls this interesting function?
ghidra_xrefs_from <address> → What does this function call?
```

### Step 3: Decompile
Read the C pseudocode for functions of interest.

```
ghidra_decompile main
ghidra_decompile 0x401230
```

If output looks wrong or incomplete, run `ghidra_analyze` first.

### Step 4: Trace Data Flow
Follow how data moves through the program.

```
ghidra_xrefs_to <recv_address>    → Where does network input go?
ghidra_decompile <handler>        → How is it processed?
ghidra_xrefs_from <handler>       → Where does processed data end up?
```

### Step 5: Clean Up and Document
Make the analysis readable for others (or your future self).

```
ghidra_rename <addr> "parse_auth_header"    → Meaningful function names
ghidra_comment <addr> "Buffer overflow here" → Document findings at locations
```

### Step 6: Report
Use the template at `templates/re-report.md` to compile findings.

## Analysis Patterns

### Binary Triage (5 minutes)
Quick assessment of what a binary does:
1. `ghidra_imports` — capabilities from API usage
2. `ghidra_strings` — interesting hardcoded values
3. `ghidra_functions` — size and complexity
4. `ghidra_decompile main` — entry point behavior

### Finding Vulnerabilities
Look for dangerous patterns:
1. Find input handlers: `ghidra_imports` → look for recv, read, fgets, scanf
2. `ghidra_xrefs_to` on each input function → find all callers
3. `ghidra_decompile` each caller → check for bounds checking
4. Look for: missing length checks before memcpy/strcpy, printf with user format strings, integer overflow in size calculations

### Firmware Analysis
1. `ghidra_segments` — identify architecture and memory layout
2. `ghidra_strings` — default credentials, debug interfaces, API keys
3. `ghidra_functions` → find main loop and command handlers
4. `ghidra_search_bytes` — look for crypto key material

### CTF Reverse Engineering
1. `ghidra_decompile main` — what input does it expect?
2. Find the check/comparison function
3. `ghidra_decompile` the check — what's it comparing against?
4. Work backwards from expected values to derive the answer

## Tips

- **Be specific with addresses.** Use `0x401230` or function name, not "that function"
- **Start broad, go deep.** Functions + strings first, then targeted decompilation
- **Name things as you go.** `ghidra_rename` makes subsequent analysis much clearer
- **Cross-reference is king.** `xrefs_to` = "who calls this?", `xrefs_from` = "what does this call?"
- **Run analysis first.** If decompilation looks off, `ghidra_analyze` fills in the gaps
- **Large binaries are slow.** Auto-analysis on 50MB+ binaries takes minutes

## Pitfalls

1. Ghidra must have a project open in CodeBrowser — tools don't work from the project manager
2. GhidraMCP is HTTP REST on port 8080, NOT SSE — don't use mcp-proxy
3. The decompiler needs analysis data — run auto-analysis before expecting good output
4. Use hex addresses with 0x prefix — decimal addresses won't resolve
5. Plugin must be enabled after every Ghidra restart (it remembers per-project though)
