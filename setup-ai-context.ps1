[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectPath,
    [switch] $SkipLaravelBoost,
    [switch] $NoWatcher
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This installer currently supports Windows 10 and Windows 11.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is required. Install Git for Windows and run the installer again.' }
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$slug = ((Split-Path $project -Leaf) -replace '[^A-Za-z0-9_-]', '-').ToLowerInvariant()
$sha = [System.Security.Cryptography.SHA256]::Create()
$pathHash = ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($project.ToLowerInvariant())))).Replace('-','').Substring(0,8).ToLowerInvariant()
$projectId = "$slug-$pathHash"
$userHomePath = [Environment]::GetFolderPath('UserProfile')

function Write-JsonFile([string] $Path, $Value) {
    $directory = Split-Path $Path -Parent
    if ($directory) { New-Item -ItemType Directory -Force -Path $directory | Out-Null }
    $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding utf8
}

function Read-McpConfig([string] $Path) {
    if ((Test-Path -LiteralPath $Path) -and (Get-Item -LiteralPath $Path).Length -gt 0) {
        try { return Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json }
        catch { throw "Gecersiz JSON duzeltilmeden devam edilemiyor: $Path" }
    }
    return [pscustomobject]@{ mcpServers = [pscustomobject]@{} }
}

function Set-McpServer([string] $Path, [string] $Name, $Definition) {
    $config = Read-McpConfig $Path
    if (-not $config.PSObject.Properties['mcpServers']) {
        $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{})
    }
    if ($config.mcpServers.PSObject.Properties[$Name]) {
        $config.mcpServers.$Name = $Definition
    } else {
        $config.mcpServers | Add-Member -NotePropertyName $Name -NotePropertyValue $Definition
    }
    Write-JsonFile $Path $config
}

function Add-UniqueLines([string] $Path, [string[]] $Lines) {
    $existing = if (Test-Path -LiteralPath $Path) { Get-Content -LiteralPath $Path -Encoding utf8 } else { @() }
    $missing = $Lines | Where-Object { $_ -notin $existing }
    if ($missing.Count -gt 0) {
        if ($existing.Count -gt 0 -and $existing[-1] -ne '') { Add-Content -LiteralPath $Path -Value '' -Encoding utf8 }
        Add-Content -LiteralPath $Path -Value $missing -Encoding utf8
    }
}

function Set-CodexMcpServer([string] $Path, [string] $Name, [string] $Command, [string[]] $Args, [string] $Cwd) {
    $text = if (Test-Path $Path) { Get-Content $Path -Raw -Encoding utf8 } else { '' }
    $start = "# BEGIN AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $end = "# END AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $tomlArgs = ($Args | ForEach-Object { '"' + $_.Replace('\','\\').Replace('"','\"') + '"' }) -join ', '
    $block = "$start`r`n[mcp_servers.$Name]`r`ncommand = `"$($Command.Replace('\','\\'))`"`r`nargs = [$tomlArgs]`r`ncwd = `"$($Cwd.Replace('\','\\'))`"`r`nstartup_timeout_sec = 20`r`ntool_timeout_sec = 60`r`n$end"
    $markedPattern = "(?s)$([regex]::Escape($start)).*?$([regex]::Escape($end))"
    if ($text -match $markedPattern) {
        $text = [regex]::Replace($text, $markedPattern, $block)
    } else {
        $tablePattern = "(?ms)^\[mcp_servers\.$([regex]::Escape($Name))\]\r?\n.*?(?=^\[|\z)"
        $text = [regex]::Replace($text, $tablePattern, '').TrimEnd() + "`r`n`r`n" + $block + "`r`n"
    }
    Set-Content -LiteralPath $Path -Value $text -Encoding utf8
}

function Set-MarkedSection([string] $Path, [string] $Name, [string] $Body) {
    $text = if (Test-Path $Path) { Get-Content $Path -Raw -Encoding utf8 } else { '' }
    $start = "<!-- BEGIN $Name -->"
    $end = "<!-- END $Name -->"
    $block = "$start`r`n$Body`r`n$end"
    $pattern = "(?s)$([regex]::Escape($start)).*?$([regex]::Escape($end))"
    if ($text -match $pattern) { $text = [regex]::Replace($text, $pattern, $block) }
    else { $text = $text.TrimEnd() + "`r`n`r`n" + $block + "`r`n" }
    Set-Content -LiteralPath $Path -Value $text -Encoding utf8
}

function Find-Uv {
    $command = Get-Command uv -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $candidate = Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\astral-sh.uv_*\uv.exe') -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($candidate) { return $candidate.FullName }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'uv bulunamadi ve winget kurulu degil.' }
    & winget install --id astral-sh.uv -e --source winget --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "uv kurulumu basarisiz: $LASTEXITCODE" }
    $candidate = Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\astral-sh.uv_*\uv.exe') -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $candidate) { throw 'uv kuruldu ancak uv.exe bulunamadi. Yeni terminal acip tekrar calistirin.' }
    return $candidate.FullName
}

function Find-CompatiblePhp {
    $candidates = @()
    $pathPhp = Get-Command php -ErrorAction SilentlyContinue
    if ($pathPhp) { $candidates += $pathPhp.Source }
    $candidates += Get-ChildItem -Path 'C:\laragon\bin\php\*\php.exe','D:\laragon\bin\php\*\php.exe' -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | ForEach-Object FullName
    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        & $candidate artisan --version *> $null
        if ($LASTEXITCODE -eq 0) { return $candidate }
    }
    return $null
}

Push-Location $project
try {
    $uv = Find-Uv
    $toolPython = Join-Path $env:APPDATA 'uv\tools\graphifyy\Scripts\python.exe'
    $graphifyReady = $false
    if (Test-Path $toolPython) {
        & $toolPython -c 'import graphify, mcp, watchdog' 2>$null
        $graphifyReady = $LASTEXITCODE -eq 0
    }
    if (-not $graphifyReady) {
        & $uv tool install 'graphifyy[mcp,watch]' --with 'mcp<2' --reinstall
        if ($LASTEXITCODE -ne 0) { throw 'Graphify kurulumu basarisiz. Acik IDE/MCP oturumlarini kapatip betigi tekrar calistirin.' }
    }

    $graphify = Join-Path $userHomePath '.local\bin\graphify.exe'
    $graphifyMcp = Join-Path $userHomePath '.local\bin\graphify-mcp.exe'
    if (-not (Test-Path $graphify) -or -not (Test-Path $graphifyMcp)) { throw 'Graphify calistirilabilir dosyalari bulunamadi.' }

    Add-UniqueLines '.graphifyignore' @('vendor/','node_modules/','public/build/','public/storage/','storage/','graphify-out/','.env*','*.key','*.pem','*.dump','*.sql','*.sql.enc')
    Add-UniqueLines '.gitignore' @('/graphify-out/')
    New-Item -ItemType Directory -Force '.cursor','.codex','.agents\rules' | Out-Null
    Add-UniqueLines '.cursorignore' @('/vendor/','/node_modules/','/graphify-out/','/public/build/','/public/storage/','/storage/logs/','.env','.env.*','*.key','*.pem','*.dump','*.sql')

    & $graphify extract . --code-only --no-cluster
    if ($LASTEXITCODE -ne 0) { throw "Graf olusturma basarisiz: $LASTEXITCODE" }
    & $graphify hook install

    $graphDefinition = [pscustomobject]@{ command = $graphifyMcp; args = @((Join-Path $project 'graphify-out\graph.json')); cwd = $project }
    Set-McpServer '.mcp.json' 'graphify' $graphDefinition
    Set-McpServer '.cursor\mcp.json' 'graphify' $graphDefinition
    Set-McpServer '.agents\mcp_config.json' 'graphify' $graphDefinition
    Set-McpServer (Join-Path $userHomePath '.gemini\config\mcp_config.json') "graphify-$projectId" $graphDefinition

    Set-CodexMcpServer '.codex\config.toml' 'graphify' $graphifyMcp @((Join-Path $project 'graphify-out\graph.json')) $project

    if ((Test-Path 'artisan') -and -not $SkipLaravelBoost) {
        $php = Find-CompatiblePhp
        if ($php) {
            $commands = & $php artisan list --raw 2>$null
            if ($commands -match '(?m)^boost:mcp\b') {
                $boostDefinition = [pscustomobject]@{ command = $php; args = @('artisan','boost:mcp'); cwd = $project }
                Set-McpServer '.mcp.json' 'laravel-boost' $boostDefinition
                Set-McpServer '.cursor\mcp.json' 'laravel-boost' $boostDefinition
                Set-McpServer '.agents\mcp_config.json' 'laravel-boost' $boostDefinition
                Set-McpServer (Join-Path $userHomePath '.gemini\config\mcp_config.json') "laravel-boost-$projectId" $boostDefinition
                Set-CodexMcpServer '.codex\config.toml' 'laravel-boost' $php @('artisan','boost:mcp') $project
            }
        }
    }

    $rule = @'
# Efficient context
Start with files or modules named by the user. Search narrowly and expand only when evidence requires it. Use the local Graphify MCP first for cross-module dependency questions; verify its results against current source. Small named-file tasks do not require a graph query. Preserve unrelated changes, use focused diffs, and run the narrowest relevant checks. Never add secrets, dumps, dependency folders, or generated output to model context.
'@
    Set-Content -LiteralPath '.agents\rules\efficient-context.md' -Value $rule -Encoding utf8
    Set-MarkedSection 'AGENTS.md' 'AI-CONTEXT-BOOTSTRAP' '## Efficient agent context

Start with files or modules named by the user and search narrowly. Use the local Graphify MCP for cross-module dependency questions, then verify results against current source. Small named-file tasks do not need Graphify. Preserve unrelated changes, prefer focused diffs, and run the narrowest relevant checks. Keep secrets, dumps, dependencies, and generated output out of model context.'

    if (-not $NoWatcher) {
        $taskName = "Graphify-$projectId-Watch"
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action = New-ScheduledTaskAction -Execute $graphify -Argument 'watch .' -WorkingDirectory $project
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
        $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
        $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Keeps the $slug Graphify graph current locally." -Force | Out-Null
        Start-ScheduledTask -TaskName $taskName
    }

    & $uv tool update-shell | Out-Null
    Write-Host "Hazir: $project" -ForegroundColor Green
    Write-Host "Project ID: $projectId"
    Write-Host "Graph: $(Join-Path $project 'graphify-out\graph.json')"
    if (-not $NoWatcher) { Write-Host "Watcher: Graphify-$projectId-Watch" }
    Write-Host 'Codex, Cursor ve Antigravity uygulamalarini yeniden baslatin veya MCP listesini yenileyin.'
} finally {
    Pop-Location
}
