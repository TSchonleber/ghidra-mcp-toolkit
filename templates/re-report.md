# Reverse Engineering Report

## Summary

| Field | Value |
|-------|-------|
| **Binary** | [filename / hash] |
| **Architecture** | [x86_64 / ARM / MIPS / etc.] |
| **Format** | [PE / ELF / Mach-O / firmware] |
| **Size** | [file size] |
| **Date** | [analysis date] |
| **Analyst** | [analyst / agent ID] |
| **Objective** | [malware triage / vuln research / firmware analysis / CTF] |
| **Classification** | [CONFIDENTIAL / TLP:AMBER / etc.] |

## Key Findings

| # | Finding | Severity | Category |
|---|---------|----------|----------|
| 1 | [Title] | Critical/High/Medium/Low/Info | [Vuln/Behavior/Indicator] |

## Binary Overview

### File Properties
- **SHA-256:** [hash]
- **MD5:** [hash]
- **Compiler:** [identified compiler/version]
- **Stripped:** [yes/no]
- **Packed:** [yes/no — packer identified]
- **Sections:** [.text, .data, .rdata, etc. with sizes]

### Imports Analysis
Key imported functions indicating capabilities:

| Category | Functions |
|----------|-----------|
| Network | [connect, send, recv, WSAStartup, etc.] |
| File I/O | [CreateFile, ReadFile, WriteFile, etc.] |
| Process | [CreateProcess, VirtualAlloc, WriteProcessMemory, etc.] |
| Crypto | [CryptEncrypt, BCryptHash, etc.] |
| Registry | [RegOpenKey, RegSetValue, etc.] |

### Strings of Interest
```
[Notable strings — URLs, IPs, credentials, debug messages, crypto constants]
```

## Detailed Analysis

### Function: [name] at [address]

**Purpose:** [what this function does]

**Decompiled pseudocode:**
```c
[decompiled code]
```

**Analysis:**
[Explanation of behavior, vulnerabilities, or indicators found]

**Cross-references:**
- Called by: [callers]
- Calls: [callees]

---

## Indicators of Compromise (if malware)

### Network Indicators
| Type | Value | Context |
|------|-------|---------|
| IP | [x.x.x.x] | C2 server |
| Domain | [example.com] | Download server |
| URL | [full URL] | Payload delivery |
| User-Agent | [string] | C2 beacon |

### Host Indicators
| Type | Value | Context |
|------|-------|---------|
| File | [path] | Dropped file |
| Registry | [key] | Persistence |
| Mutex | [name] | Instance check |
| Service | [name] | Persistence |

### MITRE ATT&CK Mapping
| Technique | ID | Evidence |
|-----------|----|----------|
| [Name] | [T####] | [How observed] |

## Appendix

### A. Complete Function List
[Relevant functions with addresses and descriptions]

### B. Raw Strings Dump
[Full strings output]

### C. Tools and Methods
- Ghidra [version] — primary analysis
- [Additional tools used]
