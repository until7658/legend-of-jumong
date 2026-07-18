[CmdletBinding()]
param(
    [ValidateSet('editor', 'script', 'project')]
    [string]$Mode = 'project',

    [string]$ScriptPath = '',

    [ValidateRange(1, 600)]
    [int]$QuitAfter = 2,

    [switch]$Windowed
)

$ErrorActionPreference = 'Stop'

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
if ($currentIdentity -like '*CodexSandboxOffline*') {
    [Console]::Error.WriteLine('[GODOT_RUNNER] Refusing to launch Godot inside the restricted Codex Windows sandbox. Re-run this command with sandbox_permissions=require_escalated.')
    exit 86
}

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$godotExecutable = 'C:\Project\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) {
    [Console]::Error.WriteLine("[GODOT_RUNNER] Godot console executable not found: $godotExecutable")
    exit 2
}

$activeGodot = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -like 'Godot_v4.7.1-stable_win64*'
})
if ($activeGodot.Count -gt 0) {
    $activeIds = ($activeGodot | ForEach-Object { $_.Id }) -join ','
    [Console]::Error.WriteLine("[GODOT_RUNNER] Another Godot process is active (PID: $activeIds). Wait for it to finish before running verification.")
    exit 87
}

$lockDirectory = Join-Path $projectRoot '.runtime_godot_verify'
$lockPath = Join-Path $lockDirectory 'verification.lock'
New-Item -ItemType Directory -Force -Path $lockDirectory | Out-Null

$lockStream = $null
try {
    $lockStream = [IO.File]::Open(
        $lockPath,
        [IO.FileMode]::OpenOrCreate,
        [IO.FileAccess]::ReadWrite,
        [IO.FileShare]::None
    )
} catch {
    [Console]::Error.WriteLine('[GODOT_RUNNER] Another verification owns the project lock. Godot checks must run sequentially.')
    exit 87
}

try {
    $godotArguments = @('--path', $projectRoot)
    if (-not $Windowed) {
        $godotArguments = @('--headless') + $godotArguments
    }

    switch ($Mode) {
        'editor' {
            $godotArguments += @('--editor', '--quit')
        }
        'script' {
            if ([string]::IsNullOrWhiteSpace($ScriptPath) -or -not $ScriptPath.StartsWith('res://')) {
                [Console]::Error.WriteLine('[GODOT_RUNNER] -Mode script requires a res:// script path.')
                exit 3
            }
            $godotArguments += @('--script', $ScriptPath)
        }
        'project' {
            $godotArguments += @('--quit-after', $QuitAfter)
        }
    }

    Write-Output "[GODOT_RUNNER] identity=$currentIdentity mode=$Mode windowed=$($Windowed.IsPresent)"
    & $godotExecutable @godotArguments
    $godotExitCode = $LASTEXITCODE
    Write-Output "[GODOT_RUNNER] exit=$godotExitCode"
    exit $godotExitCode
} finally {
    if ($null -ne $lockStream) {
        $lockStream.Dispose()
    }
    Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
}
