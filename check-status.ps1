[CmdletBinding()]
param([Parameter(Mandatory = $true)][string] $ProjectPath)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$slug = ((Split-Path $project -Leaf) -replace '[^A-Za-z0-9_-]', '-').ToLowerInvariant()
$sha = [System.Security.Cryptography.SHA256]::Create()
$hash = ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($project.ToLowerInvariant())))).Replace('-','').Substring(0,8).ToLowerInvariant()
$projectId = "$slug-$hash"
$graph = Join-Path $project 'graphify-out\graph.json'
$checks = [ordered]@{
    Project = Test-Path -LiteralPath $project -PathType Container
    Graph = Test-Path -LiteralPath $graph -PathType Leaf
    CursorMcp = Test-Path -LiteralPath (Join-Path $project '.cursor\mcp.json') -PathType Leaf
    CodexMcp = Test-Path -LiteralPath (Join-Path $project '.codex\config.toml') -PathType Leaf
    AntigravityMcp = Test-Path -LiteralPath (Join-Path $project '.agents\mcp_config.json') -PathType Leaf
    GraphifyCommand = Test-Path -LiteralPath (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.local\bin\graphify.exe') -PathType Leaf
}

$failed = $false
foreach ($entry in $checks.GetEnumerator()) {
    $state = if ($entry.Value) { 'OK' } else { 'MISSING' }
    $color = if ($entry.Value) { 'Green' } else { 'Red' }
    Write-Host ("{0,-20} {1}" -f $entry.Key, $state) -ForegroundColor $color
    if (-not $entry.Value) { $failed = $true }
}

$taskName = "Graphify-$projectId-Watch"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($task) {
    Write-Host ("{0,-20} {1}" -f 'Watcher', $task.State) -ForegroundColor $(if ($task.State -eq 'Running') { 'Green' } else { 'Yellow' })
} else {
    Write-Host ("{0,-20} {1}" -f 'Watcher', 'NOT INSTALLED') -ForegroundColor Yellow
}

if ($checks.Graph) {
    $data = Get-Content -LiteralPath $graph -Raw -Encoding utf8 | ConvertFrom-Json
    $nodeCount = if ($data.nodes) { $data.nodes.Count } else { 0 }
    $edgeCount = if ($data.links) { $data.links.Count } elseif ($data.edges) { $data.edges.Count } else { 0 }
    Write-Host "Graph nodes/edges: $nodeCount/$edgeCount"
    Write-Host "Graph updated: $((Get-Item -LiteralPath $graph).LastWriteTime)"
}

if ($failed) { exit 1 }
