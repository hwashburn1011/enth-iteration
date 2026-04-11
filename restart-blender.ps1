# blender-mcp-watchdog.ps1
# Run this in a normal PowerShell window and leave it open.
# Adjust $BlenderExe if needed.

$ErrorActionPreference = "Stop"

$BlenderExe = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
$HostName   = "127.0.0.1"
$Port       = 9876
$CheckEverySeconds = 5
$BlenderStartWaitSeconds = 10
$LogFile = "$env:USERPROFILE\blender-mcp-watchdog.log"

function Log([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    $line | Tee-Object -FilePath $LogFile -Append
}

function Test-TcpPort {
    param(
        [string]$TargetHost,
        [int]$Port,
        [int]$TimeoutMs = 1500
    )

    $client = $null
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($TargetHost, $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }
        $client.EndConnect($iar)
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($client) { $client.Close() }
    }
}

function Start-BlenderIfNeeded {
    if (-not (Get-Process blender -ErrorAction SilentlyContinue)) {
        Log "Blender not running. Starting Blender."
        Start-Process -FilePath $BlenderExe | Out-Null
        Start-Sleep -Seconds $BlenderStartWaitSeconds
    }
}

function Invoke-BlenderMcpRecovery {
    $tempPy = Join-Path $env:TEMP "blender_mcp_recover.py"

    @'
import sys
import socket
import importlib
import addon_utils

HOST = "127.0.0.1"
PORT = 9876

def port_open(host, port, timeout=1.0):
    s = socket.socket()
    s.settimeout(timeout)
    try:
        s.connect((host, port))
        return True
    except Exception:
        return False
    finally:
        try:
            s.close()
        except Exception:
            pass

print("Recovery script running...")

if port_open(HOST, PORT):
    print(f"Port {PORT} already open.")
    raise SystemExit(0)

addon_module_name = None
addon_enabled = False

for mod in addon_utils.modules():
    try:
        info = getattr(mod, "bl_info", {})
        if info.get("name") == "Blender MCP":
            addon_module_name = mod.__name__
            addon_enabled, _ = addon_utils.check(addon_module_name)
            break
    except Exception:
        pass

if not addon_module_name:
    print("ERROR: Could not find installed addon with bl_info name 'Blender MCP'.")
    raise SystemExit(2)

print(f"Found addon module: {addon_module_name}, enabled={addon_enabled}")

if not addon_enabled:
    print("Enabling Blender MCP addon...")
    addon_utils.enable(addon_module_name, default_set=True, persistent=True)

mod = importlib.import_module(addon_module_name)

if port_open(HOST, PORT):
    print(f"Port {PORT} became available after enabling addon.")
    raise SystemExit(0)

server = getattr(mod, "_watchdog_mcp_server", None)
if server is None:
    cls = getattr(mod, "BlenderMCPServer", None)
    if cls is None:
        print("ERROR: BlenderMCPServer class not found in addon module.")
        raise SystemExit(3)
    server = cls(host="localhost", port=PORT)
    setattr(mod, "_watchdog_mcp_server", server)

try:
    if not getattr(server, "running", False):
        print("Starting Blender MCP server from watchdog...")
        server.start()
    else:
        print("Server object already marked running.")
except Exception as e:
    print(f"ERROR: Failed to start server: {e}")
    raise SystemExit(4)

if port_open(HOST, PORT):
    print(f"SUCCESS: Port {PORT} is now listening.")
    raise SystemExit(0)
else:
    print(f"ERROR: Port {PORT} still not listening after recovery.")
    raise SystemExit(5)
'@ | Set-Content -Path $tempPy -Encoding UTF8

    Log "Running Blender recovery script."
    # Use the running Blender instance and execute Python in-process.
    # This opens another Blender process if needed, but the script still works for recovery.
    $proc = Start-Process -FilePath $BlenderExe `
        -ArgumentList @("--python", $tempPy) `
        -PassThru -Wait -NoNewWindow

    Log "Recovery script exited with code $($proc.ExitCode)."
    return $proc.ExitCode
}

Log "Watchdog started. Monitoring $HostName`:$Port"

while ($true) {
    try {
        if (Test-TcpPort -TargetHost $HostName -Port $Port) {
            Log "OK: Blender MCP is listening on $HostName`:$Port"
        }
        else {
            Log "FAIL: $HostName`:$Port is not listening"
            Start-BlenderIfNeeded

            if (-not (Test-TcpPort -TargetHost $HostName -Port $Port)) {
                $exitCode = Invoke-BlenderMcpRecovery
                Start-Sleep -Seconds 2

                if (Test-TcpPort -TargetHost $HostName -Port $Port) {
                    Log "RECOVERED: Blender MCP is listening again."
                }
                else {
                    Log "STILL DOWN: Recovery did not restore listener."
                }
            }
        }
    }
    catch {
        Log "ERROR: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $CheckEverySeconds
}