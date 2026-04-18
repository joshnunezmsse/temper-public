# TemperMCP 🧬

TemperMCP acts as a **"Quality Conscience"** for your AI coding agents (like Claude Desktop or Cursor). It uses the Model Context Protocol (MCP) to run **Mutation Testing** against your codebase, automatically identifying logical gaps and missing edge cases in the test suites your AI writes.

Instead of your AI just writing tests that pass the "happy path," TemperMCP forces it to write tests that are mathematically and logically bulletproof.

---

## 🔒 Privacy & Security: Your Code Stays Local

TemperMCP is designed with enterprise-grade security in mind. When you run TemperMCP:
- **Zero Code Exfiltration:** Your source code and test files **never leave your local machine**.
- **Local Execution:** All mutation testing, code analysis, and test executions happen entirely within the local Docker container running on your hardware.
- **Minimal Telemetry:** The only data transmitted to our servers is a cryptographic heartbeat containing the *number* of mutants killed (for metered billing) and your license key. We do not track file names, code snippets, or project structures.

---

## Prerequisites

- **Docker** must be installed and running on your machine.

## 1. Installation

To securely connect your AI agent to the TemperMCP Docker container, we provide a lightweight CLI wrapper. This wrapper automatically handles mounting your active workspace into the container so the AI can test your code securely.

Open your terminal and run the installation script for your operating system:

**macOS and Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.sh | bash
```

Windows (PowerShell)
```bash
irm https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.ps1 | iex
```


> **Note:** The installer will ask you which language probe you want to install (currently `js` for JavaScript/TypeScript). It will create an executable named `temper-mcp-js` on your system.

---

## 2. Licensing & Free Tier

By default, TemperMCP operates on a **Hardware-Bound Free Tier**. You do not need an account to start! You automatically receive **1,000 free mutant evaluations per month**.

To unlock unlimited usage, team analytics, and advanced reporting:
1. Visit tempermcp.dev and create an account.
2. Set up your billing to receive your private `TEMPER_LICENSE_KEY`.
3. Add this key to your agent's configuration file (see below).

---

## 3. Configuring Your AI Agent

TemperMCP works with any client that supports the Model Context Protocol. Because TemperMCP runs in an isolated container, **Docker must be running in the background** before your agent can use the tool.

### Option A: Claude Desktop

1. Open the Claude Desktop configuration file:
   * **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
   * **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

2. Add the `temper-mcp-js` server to your `mcpServers` list. If you generated a Live Key from the dashboard, place it in the `env` block. (If you want to use the Free Tier, you can omit the `env` block entirely!)

```json
{
  "mcpServers": {
    "temper-mcp-js": {
      "command": "temper-mcp-js",
      "env": {
        "TEMPER_LICENSE_KEY": "tmcp_live_YOUR_KEY_HERE"
      }
    }
  }
}
```

3. **Restart Claude Desktop.** You should now see the `find_missing_tests` tool available (represented by a hammer icon) in the UI!

### Option B: Cursor IDE

1. Open Cursor Settings (gear icon in the top right).
2. Navigate to **Features** > **MCP Servers**.
3. Click **+ Add new MCP server**.
4. Configure the fields as follows:
   * **Name:** `TemperMCP`
   * **Type:** `command`
   * **Command:** `temper-mcp-js`
5. Click **Save**.
6. To use your license key in Cursor, you currently need to set it as a system environment variable before launching Cursor, or place it in your system's global `.bashrc`/`.zshrc` profile: `export TEMPER_LICENSE_KEY="tmcp_live_..."`.

> **Note for Windows Users:** If your agent complains that it cannot find the `temper-mcp-js` command, you may need to provide the absolute path to the wrapper script (e.g., `C:\Users\YourName\.temper-mcp\bin\temper-mcp-js.cmd`).

---



## 4. How to use it

TemperMCP works best when you ask your AI agent to review its own work. After asking Claude to write tests for a file, follow up with a prompt like this:

> *"Please run the `find_missing_tests` tool on `src/math.js` and `src/math.test.js`. Tell me which mutants survived and update the test file to kill them."*

### Example AI Workflow:
1. **Agent:** Runs the `find_missing_tests` tool.
2. **TemperMCP:** Analyzes the code, runs the tests, and reports back that a "Boundary Vulnerability" survived on line 42.
3. **Agent:** Realizes it missed a `<` vs `<=` edge case, writes the missing test, and re-runs the tool to verify the mutant is killed!

---

## ⏱️ Execution Timeouts (Important)

Because TemperMCP physically mutates your code and re-runs your test suite dozens (or hundreds) of times, **a single execution can take a couple of minutes to complete**. 

Some AI agents (like Claude Desktop) have strict default timeouts that might trigger before the tool finishes analyzing a large file. To ensure a great experience:

1. **Instruct the Agent to Wait:** Add a clear instruction to your initial prompt: *"This tool takes a few minutes to run. Please be patient, wait for the final output, and do not timeout."*
2. **Scope Your Tests:** Run the tool on smaller, isolated modules rather than massive files. The fewer lines of code to mutate, the faster the testing completes.
3. **Agent/IDE Settings:** If your specific IDE or AI client has a configurable timeout setting for external tools or LLM requests, consider increasing it to at least 3-5 minutes.

> **💡 Tip for Claude Code users:** You can explicitly configure the MCP timeout and max output tokens using environment variables when launching Claude from your terminal. For example, to set a 5-minute (300,000ms) timeout and a 50,000 token output limit, launch it like this:
> ```bash
> MCP_TIMEOUT=300000 MAX_MCP_OUTPUT_TOKENS=50000 claude
> ```

---

## Advanced Configuration (Custom Test Commands)

By default, TemperMCP assumes you are using the native Node.js test runner (`node --test`). If your project uses Jest or Vitest, you can tell the AI agent to use a custom test command when it invokes the tool.

Just tell Claude:
> *"When you run the mutation tool, please use the custom test_command: `npx jest`"*

---

## Uninstallation

If you need to remove the CLI wrapper from your system:

**macOS and Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.sh | bash -s -- uninstall
```

**Windows (PowerShell)**
```powershell
iex "& { $(irm https://raw.githubusercontent.com/joshnunezmsse/temper-public/main/install-cli.ps1) } -Action uninstall"
```