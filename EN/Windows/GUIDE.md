# Windows user guide

## Requirements

Git, PowerShell 5.1+, WinGet, internet access for first installation. Write access to the target project is required. Laravel Boost is optional and requires a working PHP/Composer installation.

## Install and repair

Drag the project folder onto `INSTALL.bat`, or double-click and enter its full path. The installer is repeatable and merges MCP JSON settings. For non-interactive use:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app" -ContextProfile Minimal
```

Minimal enables five core Graphify tools. Balanced adds architecture tools and Laravel Boost when available. Full enables all Graphify tools. The graph is built locally with `--code-only`; no API key is needed for extraction.

## Files and automation

The installer creates project-scoped Codex, Cursor, and Antigravity MCP configuration, short agent rules, `.graphifyignore`, Git hooks, and a Windows Scheduled Task. It also creates `.codex/cloud/setup.sh`, `maintenance.sh`, and `query.sh` for Codex Cloud. Commit the cloud scripts to your target repository, then enter `bash .codex/cloud/setup.sh` and `bash .codex/cloud/maintenance.sh` in that repository's Codex Cloud environment settings.

The cloud query helper defaults to an 800-token output budget. Cloud environment settings must be configured in Codex; a local installer cannot change a remote account setting.

## Check and troubleshoot

Drag the project folder onto `CHECK_STATUS.bat`. The checker reports MCP files, graph, and tool availability. If MCP tools are absent, refresh the editor's MCP list or restart it. If Laravel Boost is absent, install project dependencies and a compatible PHP version, then rerun the installer. If the graph is stale, run `graphify update .` inside the project.

Token savings depend on the task and model; no fixed reduction is guaranteed. See [security guidance](SECURITY.md).
