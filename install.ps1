# Installs/updates personal Claude Code skills from this repo onto the current machine (Windows/PowerShell).
# Usage (run in PowerShell):
#   git clone https://github.com/thapar25/claude-skills.git "$env:USERPROFILE\.claude-skills" 2>$null; if (-not $?) { git -C "$env:USERPROFILE\.claude-skills" pull --ff-only }
#   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude-skills\install.ps1"

$ErrorActionPreference = "Stop"

$RepoUrl   = "https://github.com/thapar25/claude-skills.git"
$CloneDir  = Join-Path $env:USERPROFILE ".claude-skills"
$TargetDir = Join-Path $env:USERPROFILE ".claude\skills"

if (Test-Path (Join-Path $CloneDir ".git")) {
    git -C $CloneDir pull --ff-only
} else {
    git clone $RepoUrl $CloneDir
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

Get-ChildItem -Path (Join-Path $CloneDir "skills") -Directory | ForEach-Object {
    $name   = $_.Name
    $source = $_.FullName
    $link   = Join-Path $TargetDir $name

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.LinkType) {
            Remove-Item $link -Force -Recurse
        } else {
            $backup = "$link.bak.$([DateTimeOffset]::Now.ToUnixTimeSeconds())"
            Write-Host "Existing non-link at $link, backing up to $backup"
            Move-Item $link $backup
        }
    }

    # Directory junctions don't need admin rights or Developer Mode, unlike symlinks - try that first.
    try {
        New-Item -ItemType Junction -Path $link -Target $source | Out-Null
        Write-Host "Linked $name (junction)"
    } catch {
        try {
            New-Item -ItemType SymbolicLink -Path $link -Target $source | Out-Null
            Write-Host "Linked $name (symlink)"
        } catch {
            Write-Warning "Could not create a junction or symlink for $name. Copying instead - this copy won't auto-update, re-run this script after every 'git pull' to refresh it."
            Copy-Item -Path $source -Destination $link -Recurse -Force
        }
    }
}

Write-Host "Done. Skills installed from $CloneDir into $TargetDir"

# --- "Claude needs you" sound hook -------------------------------------------
# Plays a short sound whenever Claude Code wants your attention: a permission
# prompt (PermissionRequest), a multiple-choice question (Elicitation), or the
# general attention notification (Notification, e.g. idle/away nudges).
$SoundFile    = Join-Path $CloneDir "assets\sounds\pop-402322.mp3"
$SettingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"
$HookMarker   = "claude-skills:notification-sound"
$HookEvents   = @("Notification", "PermissionRequest", "Elicitation")

# Outer quoting is single-quoted deliberately: on machines with Git Bash
# installed, Claude Code's hook runner invokes "command" hooks via bash, and
# bash expands $-variables even inside double quotes. Wrapping the PowerShell
# script in single quotes (with the path literal double-quoted instead, so it
# doesn't clash) stops bash from mangling $player before it ever reaches
# powershell.exe.
$innerCmd = 'Add-Type -AssemblyName presentationCore; $player = New-Object System.Windows.Media.MediaPlayer; $player.Open([uri]"{0}"); $player.Play(); Start-Sleep -Seconds 3' -f $SoundFile
$hookCommand = "powershell.exe -NoProfile -Command '$innerCmd'"

if (Test-Path $SettingsPath) {
    $settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path $SettingsPath) | Out-Null
    $settings = [PSCustomObject]@{}
}

if (-not $settings.PSObject.Properties['hooks']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{})
}

foreach ($eventName in $HookEvents) {
    if (-not $settings.hooks.PSObject.Properties[$eventName]) {
        $settings.hooks | Add-Member -MemberType NoteProperty -Name $eventName -Value @()
    }

    $kept = @($settings.hooks.$eventName | Where-Object {
        $entry = $_
        -not (@($entry.hooks) | Where-Object {
            $_.statusMessage -eq $HookMarker -or ($_.command -and $_.command -like '*pop-402322.mp3*')
        })
    })

    $newEntry = [PSCustomObject]@{
        matcher = ""
        hooks   = @([PSCustomObject]@{
            type          = "command"
            command       = $hookCommand
            statusMessage = $HookMarker
        })
    }

    $settings.hooks.$eventName = @($kept) + @($newEntry)
}

($settings | ConvertTo-Json -Depth 20) | Set-Content -Path $SettingsPath -Encoding utf8
Write-Host "Notification sound hook installed in $SettingsPath for: $($HookEvents -join ', ')"
