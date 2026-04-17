param (
    [string]$Action = "",
    [string]$TargetLang = ""
)

$InstallDir = "$env:USERPROFILE\.temper-mcp\bin"

if ($Action -eq "uninstall" -or $Action -eq "--uninstall") {
    $Lang = if ($TargetLang) { $TargetLang } else { "js" }
    $WrapperPath = "$InstallDir\temper-mcp-${Lang}.cmd"
    Write-Host "🗑️ Uninstalling TemperMCP CLI Wrapper for ${Lang}..."
    if (Test-Path $WrapperPath) {
        Remove-Item $WrapperPath -Force
        Write-Host "✅ Uninstallation complete!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Wrapper not found at $WrapperPath." -ForegroundColor Yellow
    }
    exit
}

if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: Docker is not installed or not in your PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Select which TemperMCP server to install:"
Write-Host "1) js (JavaScript/TypeScript) - Default"
# Write-Host "2) python"
# Write-Host "3) java"
$choice = Read-Host "Enter choice [1]"

switch ($choice) {
    "1" { $Lang = "js" }
    # "2" { $Lang = "python" }
    # "3" { $Lang = "java" }
    ""  { $Lang = "js" }
    default { Write-Host "Unrecognized choice. Defaulting to js."; $Lang = "js" }
}

if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

$WrapperPath = "$InstallDir\temper-mcp-${Lang}.cmd"

Write-Host "🧬 Installing TemperMCP CLI Wrapper for ${Lang}..."

# Generate a hardware-based anonymous key to prevent free-tier abuse
$MachineId = (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID
if (-not $MachineId) { $MachineId = $env:COMPUTERNAME }
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($MachineId)
$HashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash($Bytes)
$HashString = ([System.BitConverter]::ToString($HashBytes) -replace '-').ToLower().Substring(0, 32)
$DefaultKey = "anon_$HashString"

$ScriptContent = @"
@echo off
REM TemperMCP CLI Wrapper (${Lang})

if "%TEMPER_LICENSE_KEY%"=="" set TEMPER_LICENSE_KEY=$DefaultKey
if "%TEMPER_BILLING_URL%"=="" set TEMPER_BILLING_URL=https://api.tempermcp.dev/v1/heartbeat
if "%TEMPER_IMAGE%"=="" set TEMPER_IMAGE=joshnunezmsse/temper-mcp:${Lang}

docker run -i --rm -e TEMPER_ENV=production -e TEMPER_LICENSE_KEY="%TEMPER_LICENSE_KEY%" -e TEMPER_BILLING_URL="%TEMPER_BILLING_URL%" -v "%cd%:/code" "%TEMPER_IMAGE%"
"@

Set-Content -Path $WrapperPath -Value $ScriptContent

$EscapedPath = $WrapperPath -replace '\\', '\\'

Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host "You can now configure your AI Agent (like VS Code or Claude Desktop) using this simplified settings block:"
Write-Host ""
Write-Host "{`"mcpServers`": {"
Write-Host "  `"temper-mcp-${Lang}`": {"
Write-Host "    `"command`": `"$EscapedPath`","
Write-Host "    `"env`": { `"TEMPER_LICENSE_KEY`": `"your_generated_live_key`" }"
Write-Host "} } }"