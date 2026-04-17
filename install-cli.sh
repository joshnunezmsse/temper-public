#!/bin/bash

# Find the absolute path to Docker. This is crucial because GUI apps 
# (like Claude Desktop) often do not inherit the user's full shell PATH.
DOCKER_BIN=$(command -v docker)
if [ -z "$DOCKER_BIN" ]; then
  echo "❌ Error: Docker is not installed or not in your PATH."
  exit 1
fi

if [ "$1" = "uninstall" ] || [ "$1" = "--uninstall" ]; then
  MCP_LANG="${2:-js}"
  CLI_PATH="/usr/local/bin/temper-mcp-${MCP_LANG}"
  echo "🗑️  Uninstalling TemperMCP CLI Wrapper for ${MCP_LANG}..."
  echo "Requesting sudo permissions to remove $CLI_PATH..."
  sudo rm -f "$CLI_PATH"
  echo "✅ Uninstallation complete!"
  exit 0
fi

echo "Select which TemperMCP server to install:"
echo "1) js (JavaScript/TypeScript) - Default"
# echo "2) python"
# echo "3) java"
read -p "Enter choice [1]: " choice

case "$choice" in
  1|"") MCP_LANG="js" ;;
  # 2) MCP_LANG="python" ;;
  # 3) MCP_LANG="java" ;;
  *) echo "Unrecognized choice. Defaulting to js."; MCP_LANG="js" ;;
esac

CLI_PATH="/usr/local/bin/temper-mcp-${MCP_LANG}"
TEMP_SCRIPT_PATH="/tmp/temper-mcp-${MCP_LANG}"

echo "🧬 Installing TemperMCP CLI Wrapper for ${MCP_LANG}..."

# Generate a hardware-based anonymous key to prevent free-tier abuse
if [ "$(uname)" = "Darwin" ]; then
  MACHINE_ID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { print $3; }' | sed 's/"//g')
elif [ -f /etc/machine-id ]; then
  MACHINE_ID=$(cat /etc/machine-id)
else
  MACHINE_ID=$(hostname)
fi

if command -v shasum >/dev/null 2>&1; then
  ANON_HASH=$(echo -n "$MACHINE_ID" | shasum -a 256 | cut -c 1-32)
elif command -v sha256sum >/dev/null 2>&1; then
  ANON_HASH=$(echo -n "$MACHINE_ID" | sha256sum | cut -c 1-32)
else
  ANON_HASH="fallback_$(date +%s)"
fi
DEFAULT_KEY="anon_${ANON_HASH}"

cat << EOF > "$TEMP_SCRIPT_PATH"
#!/bin/bash

# TemperMCP CLI Wrapper (${MCP_LANG})
# Automatically injects the current working directory into the Docker container

LICENSE_KEY="\${TEMPER_LICENSE_KEY:-$DEFAULT_KEY}"
BILLING_URL="\${TEMPER_BILLING_URL:-https://api.tempermcp.dev/v1/heartbeat}"
IMAGE_NAME="\${TEMPER_IMAGE:-joshnunez/temper-mcp:${MCP_LANG}}"

# The agent will execute this command in the context of the workspace root, 
# so \$(pwd) accurately reflects the codebase we want to test.
exec "$DOCKER_BIN" run -i --rm \
  -e TEMPER_ENV=production \
  -e TEMPER_LICENSE_KEY="\$LICENSE_KEY" \
  -e TEMPER_BILLING_URL="\$BILLING_URL" \
  -v "\$(pwd):/code" \
  "\$IMAGE_NAME"
EOF

chmod +x "$TEMP_SCRIPT_PATH"

echo "Requesting sudo permissions to move the CLI to $CLI_PATH..."
sudo mv "$TEMP_SCRIPT_PATH" "$CLI_PATH"

echo "✅ Installation complete!"
echo "You can now configure your AI Agent (like VS Code or Claude Desktop) using this simplified settings block:"
echo ""
echo '{"mcpServers": {'
echo "  \"temper-mcp-${MCP_LANG}\": {"
echo "    \"command\": \"temper-mcp-${MCP_LANG}\","
echo '    "env": { "TEMPER_LICENSE_KEY": "your_generated_live_key" }'
echo '} } }'