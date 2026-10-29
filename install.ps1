[CmdletBinding()]
param(
    [string]$TargetRoot = (Join-Path $HOME '.codex\skills'),
    [switch]$WithSuperpowers,
    [switch]$WithCustom,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentSkillsRoot = Join-Path $HOME '.agents\skills'

function Test-Skill([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return (Test-Path -LiteralPath (Join-Path $Path 'SKILL.md'))
}

function Assert-UnderTarget([string]$Path) {
    $target = [System.IO.Path]::GetFullPath($TargetRoot).TrimEnd('\')
    $candidate = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    if (-not $candidate.StartsWith($target + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to write outside TargetRoot: $candidate"
    }
}

function Install-SkillFrom([string]$Source, [string]$Name) {
    $dst = Join-Path $TargetRoot $Name

    if (-not (Test-Skill $Source)) { throw "Missing bundled skill: $Source" }

    if (Test-Skill $dst) {
        if (-not $Force) {
            Write-Host ("  [skip] {0} already installed" -f $Name) -ForegroundColor DarkYellow
            return
        }
        Assert-UnderTarget $dst
        Remove-Item -LiteralPath $dst -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Get-ChildItem -LiteralPath $Source -Force | Copy-Item -Destination $dst -Recurse -Force
    Write-Host ("  [ok]   {0} -> {1}" -f $Name, $dst) -ForegroundColor Green
}

function Install-RepoSkill([string]$Name) {
    Install-SkillFrom (Join-Path $RepoRoot (Join-Path 'skills' $Name)) $Name
}

function Install-CustomSkill {
    Install-SkillFrom (Join-Path $RepoRoot 'custom\wangtao-workflow') 'wangtao-workflow'
}

function Install-Superpowers {
    $tmp = Join-Path $env:TEMP ('superpowers-' + [guid]::NewGuid().ToString('N'))
    try {
        Write-Host '  cloning obra/superpowers ...'
        git clone --depth 1 https://github.com/obra/superpowers.git $tmp
        if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }

        $src = Join-Path $tmp 'skills'
        if (-not (Test-Path -LiteralPath $src)) { throw 'Upstream layout changed: skills/ not found.' }

        Get-ChildItem -LiteralPath $src -Directory | ForEach-Object {
            $name = $_.Name
            $dst = Join-Path $TargetRoot $name

            if (Test-Skill $dst) {
                if (-not $Force) {
                    Write-Host ("  [skip] {0} already installed" -f $name) -ForegroundColor DarkYellow
                    return
                }
                Assert-UnderTarget $dst
                Remove-Item -LiteralPath $dst -Recurse -Force
            }

            New-Item -ItemType Directory -Force -Path $dst | Out-Null
            Get-ChildItem -LiteralPath $_.FullName -Force | Copy-Item -Destination $dst -Recurse -Force
            Write-Host ("  [ok]   {0}" -f $name) -ForegroundColor Green
        }
    }
    finally {
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
    }
}

function Show-Status {
    $rows = @(
        @{ Skill = 'Superpowers';         Kind = 'community'; Paths = @((Join-Path $AgentSkillsRoot 'using-superpowers'), (Join-Path $TargetRoot 'using-superpowers')) },
        @{ Skill = 'PDF';                 Kind = 'built-in';  Paths = @() },
        @{ Skill = 'humanizer-zh';        Kind = 'bundled';   Paths = @((Join-Path $TargetRoot 'humanizer-zh')) },
        @{ Skill = 'planning-with-files'; Kind = 'bundled';   Paths = @((Join-Path $TargetRoot 'planning-with-files')) },
        @{ Skill = 'frontend-design';     Kind = 'built-in';  Paths = @((Join-Path $TargetRoot 'frontend-design'), (Join-Path $AgentSkillsRoot 'frontend-design')) },
        @{ Skill = 'code-review';         Kind = 'community'; Paths = @((Join-Path $AgentSkillsRoot 'code-review'), (Join-Path $TargetRoot 'code-review')) },
        @{ Skill = 'skill-creator';       Kind = 'built-in';  Paths = @((Join-Path $TargetRoot '.system\skill-creator')) }
    )

    $rows | ForEach-Object {
        $found = $false
        foreach ($path in $_.Paths) {
            if (Test-Skill $path) { $found = $true; break }
        }

        $status = if ($_.Paths.Count -eq 0) { 'built-in' }
                  elseif ($found) { 'installed' }
                  else { 'missing' }

        [pscustomobject]@{ Skill = $_.Skill; Kind = $_.Kind; Status = $status }
    } | Format-Table -AutoSize
}

Write-Host 'Codex skills installer' -ForegroundColor Cyan
Write-Host ("Target: {0}" -f $TargetRoot)
New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

Write-Host ''
Write-Host 'Bundled MIT skills:' -ForegroundColor Cyan
Install-RepoSkill 'humanizer-zh'
Install-RepoSkill 'planning-with-files'

if ($WithCustom) {
    Write-Host ''
    Write-Host 'Custom skill:' -ForegroundColor Cyan
    Install-CustomSkill
}

Write-Host ''
if ($WithSuperpowers) {
    Write-Host 'Superpowers:' -ForegroundColor Cyan
    Install-Superpowers
}
else {
    $probe = Join-Path $AgentSkillsRoot 'using-superpowers'
    if (Test-Skill $probe) {
        Write-Host '  [skip] Superpowers already installed' -ForegroundColor DarkYellow
    }
    else {
        Write-Host '  [info] Superpowers missing; rerun with -WithSuperpowers to install from upstream.' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Status:' -ForegroundColor Cyan
Show-Status

Write-Host ''
Write-Host 'Note: planning-with-files installs skill instructions only.' -ForegroundColor Gray
Write-Host 'Per-turn hook injection requires enabling the upstream Codex plugin/hooks separately.' -ForegroundColor Gray
Write-Host 'Restart Codex if a newly installed skill does not appear.' -ForegroundColor Gray
