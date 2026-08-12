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
