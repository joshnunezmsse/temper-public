# TemperMCP

This is the core implementation of TemperMCP, delivered via the Model Context Protocol (MCP). It acts as a "Quality Conscience" for AI coding agents, analyzing their unit tests by introducing logical mutations into the source code and verifying if the test suite catches them.

## Prerequisites

- Docker installed and running.

## Host CLI Wrapper (Easy Installation)

To make it easier to configure your AI Agent (like Gemini Code Assist or Claude Desktop), you can install a global `temper-mcp` CLI wrapper. This handles the complex Docker volume mounts automatically.

### Quick Install (Recommended)
Run the following command in your terminal to download and run the installer automatically.

macOS and Linux
```bash
curl -fsSL https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.sh | bash
```

Windows (PowerShell)
```bash
irm https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.ps1 | iex
```

### Install from Source
If you have cloned the repository locally, you can install directly from the source directory:

```bash
# macOS and Linux
./install-cli.sh

# Windows (PowerShell)
.\install-cli.ps1
```

To uninstall:
```bash
# macOS and Linux
./install-cli.sh uninstall

# Windows (PowerShell)
.\install-cli.ps1 uninstall

# Windows (PowerShell - via web)
iex "& { $(irm https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.ps1) } -Action uninstall"
```