[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ProjectPath,
    [ValidateSet('Minimal','Balanced','Full')]
    [string] $ContextProfile = 'Minimal',
    [switch] $SkipLaravelBoost,
    [switch] $EnableLaravelBoost,
    [switch] $EnableHooks,
    [switch] $EnableWatcher,
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
$trustedProxyDirectory = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) ("AI-Context-Bootstrap\$projectId")
$trustedProxy = Join-Path $trustedProxyDirectory 'graphify-mcp-proxy.py'

function Assert-SafeManagedPath([string] $Path) {
    $candidate = [System.IO.Path]::GetFullPath($Path)
    while ($candidate) {
        if (Test-Path -LiteralPath $candidate) {
            $entry = Get-Item -LiteralPath $candidate -Force
            if (($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Refusing redirected configuration path: $candidate"
            }
        }
        $parent = Split-Path -Path $candidate -Parent
        if (-not $parent -or $parent -eq $candidate) { break }
        $candidate = $parent
    }
}

function Write-JsonFile([string] $Path, $Value) {
    $directory = Split-Path $Path -Parent
    if ($directory) { New-Item -ItemType Directory -Force -Path $directory | Out-Null }
    $tempPath = "$Path.ai-context-$PID.tmp"
    try {
        $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $tempPath -Encoding utf8
        Move-Item -LiteralPath $tempPath -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
    }
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
        $old = $config.mcpServers.PSObject.Properties[$Name].Value
        if ($null -eq $old -or $old.cwd -ne $project) {
            throw "Refusing to overwrite an unmanaged MCP server ($Name) in $Path"
        }
        $config.mcpServers.$Name = $Definition
    } else {
        $config.mcpServers | Add-Member -NotePropertyName $Name -NotePropertyValue $Definition
    }
    Write-JsonFile $Path $config
}

function Remove-McpServer([string] $Path, [string] $Name, [string] $ExpectedCwd = '') {
    if (-not (Test-Path -LiteralPath $Path) -or (Get-Item -LiteralPath $Path).Length -eq 0) { return }
    $config = Read-McpConfig $Path
    $property = $config.mcpServers.PSObject.Properties[$Name]
    if (-not $property) { return }
    if ($ExpectedCwd -and $property.Value.cwd -ne $ExpectedCwd) { return }
    $config.mcpServers.PSObject.Properties.Remove($Name)
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

function Set-CodexMcpServer([string] $Path, [string] $Name, [string] $Command, [string[]] $Args, [string] $Cwd, [string[]] $EnabledTools = @()) {
    $text = if (Test-Path $Path) { Get-Content $Path -Raw -Encoding utf8 } else { '' }
    $start = "# BEGIN AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $end = "# END AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $tomlArgs = ($Args | ForEach-Object { '"' + $_.Replace('\','\\').Replace('"','\"') + '"' }) -join ', '
    $toolLine = if ($EnabledTools.Count -gt 0) { "`r`nenabled_tools = [" + (($EnabledTools | ForEach-Object { '"' + $_ + '"' }) -join ', ') + ']' } else { '' }
    $block = "$start`r`n[mcp_servers.$Name]`r`ncommand = `"$($Command.Replace('\','\\'))`"`r`nargs = [$tomlArgs]`r`ncwd = `"$($Cwd.Replace('\','\\'))`"`r`nstartup_timeout_sec = 20`r`ntool_timeout_sec = 60$toolLine`r`n$end"
    $markedPattern = "(?s)$([regex]::Escape($start)).*?$([regex]::Escape($end))"
    if ($text -match $markedPattern) {
        $text = [regex]::Replace($text, $markedPattern, $block)
    } else {
        $tablePattern = "(?m)^\[mcp_servers\.$([regex]::Escape($Name))\]\s*$"
        if ($text -match $tablePattern) {
            throw "Refusing to overwrite unmarked Codex MCP server: $Name"
        }
        $text = $text.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
    }
    Set-Content -LiteralPath $Path -Value $text -Encoding utf8
}

function Remove-CodexMcpServer([string] $Path, [string] $Name) {
    if (-not (Test-Path $Path)) { return }
    $text = Get-Content $Path -Raw -Encoding utf8
    $start = "# BEGIN AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $end = "# END AI-CONTEXT-BOOTSTRAP $($Name.ToUpperInvariant())"
    $pattern = "(?s)\r?\n?$([regex]::Escape($start)).*?$([regex]::Escape($end))\r?\n?"
    $text = [regex]::Replace($text, $pattern, "`r`n").Trim() + "`r`n"
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
    $drive = (Get-Location).Drive.Name
    $pathPhp = Get-Command php -ErrorAction SilentlyContinue
    if ($pathPhp) { $candidates += $pathPhp.Source }
    $priorityPaths = @(
        "$drive`:\laragon\bin\php\*\php.exe",
        'C:\laragon\bin\php\*\php.exe',
        'D:\laragon\bin\php\*\php.exe'
    )
    $laragonPhps = Get-ChildItem -Path $priorityPaths -ErrorAction SilentlyContinue |
        Select-Object -Unique FullName |
        Sort-Object {
            if ($_.FullName -match 'php-(\d+\.\d+\.\d+)') {
                [version]$matches[1]
            } else {
                [version]'0.0.0'
            }
        } -Descending |
        ForEach-Object FullName
    $candidates += $laragonPhps
    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (Test-Path $candidate) {
            & $candidate artisan --version *> $null
            if ($LASTEXITCODE -eq 0) { return $candidate }
        }
    }
    return $null
}

Push-Location $project

# Restore existing project and user configuration when setup fails.
$trackedFiles = @(
    (Join-Path $project '.mcp.json'),
    (Join-Path $project '.cursor\mcp.json'),
    (Join-Path $project '.codex\config.toml'),
    (Join-Path $project '.agents\mcp_config.json'),
    (Join-Path $userHomePath '.gemini\config\mcp_config.json'),
    (Join-Path $project 'AGENTS.md'),
    (Join-Path $project '.graphifyignore'),
    (Join-Path $project '.cursorignore'),
    (Join-Path $project '.gitignore'),
    (Join-Path $project '.agents\rules\efficient-context.md'),
    (Join-Path $project '.codex\graphify-mcp-proxy.py'),
    $trustedProxy,
    (Join-Path $project '.codex\cloud\setup.sh'),
    (Join-Path $project '.codex\cloud\query.sh'),
    (Join-Path $project '.codex\cloud\maintenance.sh'),
    (Join-Path $project '.codex\cloud\README.md')
)
$backupRoot = $null
$backedUp = @{}
$setupComplete = $false
try {
    $backupRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ai-context-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    for ($index = 0; $index -lt $trackedFiles.Count; $index++) {
        $file = $trackedFiles[$index]
        Assert-SafeManagedPath $file
        if (Test-Path -LiteralPath $file) {
            $fileInfo = Get-Item -LiteralPath $file -Force
            if ($fileInfo.PSIsContainer -or ($fileInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                throw "Refusing to overwrite directory or symlink: $file"
            }
            Copy-Item -LiteralPath $file -Destination (Join-Path $backupRoot "$index") -Force
            $backedUp[$index] = $true
        } else {
            $backedUp[$index] = $false
        }
    }
    Assert-SafeManagedPath (Join-Path $project 'graphify-out\graph.json')
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
    Add-UniqueLines '.gitignore' @('/graphify-out/','!/.codex/','/.codex/*','!/.codex/graphify-mcp-proxy.py','!/.codex/cloud/','!/.codex/cloud/**')
    New-Item -ItemType Directory -Force '.cursor','.codex','.codex\cloud','.agents\rules' | Out-Null
    New-Item -ItemType Directory -Force -Path $trustedProxyDirectory | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'graphify-mcp-proxy.py') -Destination $trustedProxy -Force
    Add-UniqueLines '.cursorignore' @('/vendor/','/node_modules/','/graphify-out/','/public/build/','/public/storage/','/storage/logs/','.env','.env.*','*.key','*.pem','*.dump','*.sql')
    $cloudTemplateDirectory = Join-Path $PSScriptRoot 'cloud'
    foreach ($cloudFile in @('setup.sh','maintenance.sh','query.sh','README.md')) {
        $source = Join-Path $cloudTemplateDirectory $cloudFile
        if (-not (Test-Path -LiteralPath $source)) { throw "Missing Codex Cloud template: $source" }
        $content = Get-Content -LiteralPath $source -Raw -Encoding utf8
        $content = $content.Replace('__DEFAULT_PROFILE__', $ContextProfile)
        $destination = Join-Path '.codex\cloud' $cloudFile
        [System.IO.File]::WriteAllText($destination, $content, [System.Text.UTF8Encoding]::new($false))
    }

    & $graphify extract . --code-only --no-cluster
    if ($LASTEXITCODE -ne 0) { throw "Graf olusturma basarisiz: $LASTEXITCODE" }
    if ($ContextProfile -ne 'Minimal') {
        & $graphify cluster-only . --no-label --no-viz
        if ($LASTEXITCODE -ne 0) { throw "Graph clustering failed: $LASTEXITCODE" }
    }
    if ($EnableHooks) {
        & $graphify hook install
        if ($LASTEXITCODE -ne 0) { throw "Graphify Git hook installation failed: $LASTEXITCODE" }
    } else { Write-Host "Git hooks unchanged (opt in with -EnableHooks)." }

    $graphDisabledTools = switch ($ContextProfile) {
        'Minimal' { @('get_community','god_nodes','list_prs','get_pr_impact','triage_prs') }
        'Balanced' { @('list_prs','get_pr_impact','triage_prs') }
        default { @() }
    }
    $graphEnabledTools = switch ($ContextProfile) {
        'Minimal' { @('query_graph','get_node','get_neighbors','shortest_path','graph_stats') }
        'Balanced' { @('query_graph','get_node','get_neighbors','get_community','god_nodes','shortest_path','graph_stats') }
        default { @() }
    }
    $proxyArgs = @($trustedProxy, $graphifyMcp, (Join-Path $project 'graphify-out\graph.json'), $ContextProfile, $project)
    if (-not (Test-Path -LiteralPath $toolPython)) { throw 'Graphify Python interpreter could not be found.' }
    $graphDefinition = [pscustomobject]@{ command = $toolPython; args = $proxyArgs; cwd = $project }
    $antigravityGraphDefinition = [pscustomobject]@{ command = $toolPython; args = $proxyArgs; cwd = $project; disabledTools = $graphDisabledTools }
    Set-McpServer '.mcp.json' 'graphify' $graphDefinition
    Set-McpServer '.cursor\mcp.json' 'graphify' $graphDefinition
    Remove-McpServer '.agents\mcp_config.json' 'graphify' $project
    Set-McpServer '.agents\mcp_config.json' "graphify-$projectId" $antigravityGraphDefinition
    Set-McpServer (Join-Path $userHomePath '.gemini\config\mcp_config.json') "graphify-$projectId" $antigravityGraphDefinition

    Set-CodexMcpServer '.codex\config.toml' 'graphify' $toolPython $proxyArgs $project $graphEnabledTools

    $boostConfigured = $false
    if ((Test-Path 'artisan') -and $EnableLaravelBoost -and -not $SkipLaravelBoost -and $ContextProfile -ne 'Minimal') {
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
                $boostConfigured = $true
            }
        }
    }
    if (-not $boostConfigured) {
        # Never delete someone else's Laravel Boost configuration during setup.
        Write-Host 'Laravel Boost unchanged; removal requires an explicit cleanup operation.'
    }

    $rule = @'
# Efficient context
Start with files or modules named by the user. Search narrowly and expand only when evidence requires it. Use the local Graphify MCP first for cross-module dependency questions; in Codex Cloud, use `bash .codex/cloud/query.sh "question"` when MCP is unavailable and keep the default 800-token budget unless more detail is needed. Verify graph results against current source. Small named-file tasks do not require a graph query. Preserve unrelated changes, use focused diffs, and run the narrowest relevant checks. Never add secrets, dumps, dependency folders, or generated output to model context.
'@
    Set-Content -LiteralPath '.agents\rules\efficient-context.md' -Value $rule -Encoding utf8
    Set-MarkedSection 'AGENTS.md' 'AI-CONTEXT-BOOTSTRAP' '## Efficient agent context

Start with files or modules named by the user and search narrowly. Use the local Graphify MCP for cross-module dependency questions. In Codex Cloud, use `bash .codex/cloud/query.sh "question"` when MCP is unavailable and keep the default 800-token budget unless more detail is needed. Verify graph results against current source. Small named-file tasks do not need Graphify. Preserve unrelated changes, prefer focused diffs, and run the narrowest relevant checks. Keep secrets, dumps, dependencies, and generated output out of model context.'

    if ($EnableWatcher -and -not $NoWatcher) {
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
    Write-Host "Context profile: $ContextProfile"
    Write-Host "Graph: $(Join-Path $project 'graphify-out\graph.json')"
    Write-Host 'Codex Cloud: commit .codex/cloud, then configure its setup and maintenance scripts.'
    if ($EnableWatcher -and -not $NoWatcher) { Write-Host "Watcher: Graphify-$projectId-Watch" }
    Write-Host 'Codex, Cursor ve Antigravity uygulamalarini yeniden baslatin veya MCP listesini yenileyin.'
    $setupComplete = $true
} finally {
    if (-not $setupComplete -and $backupRoot) {
        Write-Warning 'Setup failed; restoring original configuration files.'
        for ($index = 0; $index -lt $trackedFiles.Count; $index++) {
            if (-not $backedUp.ContainsKey($index)) { continue }
            $file = $trackedFiles[$index]
            try {
                if ($backedUp[$index]) {
                    $parent = Split-Path -Path $file -Parent
                    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
                    Copy-Item -LiteralPath (Join-Path $backupRoot "$index") -Destination $file -Force
                } elseif (Test-Path -LiteralPath $file) {
                    Remove-Item -LiteralPath $file -Force
                }
            } catch {
                Write-Warning "Could not restore $file : $($_.Exception.Message)"
            }
        }
    }
    if ($backupRoot -and (Test-Path -LiteralPath $backupRoot)) {
        Remove-Item -LiteralPath $backupRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    Pop-Location
}

