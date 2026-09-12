# User guide

## Requirements

- Windows 10 or Windows 11
- Git for Windows
- WinGet
- Internet access during first installation
- Write access to the target repository

## Install or repair

Drag a project directory onto `INSTALL_OR_REPAIR.bat`, or run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app"
```

The operation is designed to be repeatable. It merges MCP JSON configuration and replaces only its marked Codex and AGENTS sections.

## Verify

Drag the project directory onto `CHECK_STATUS.bat`, or run:

```powershell
powershell -ExecutionPolicy Bypass -File .\check-status.ps1 -ProjectPath "C:\projects\my-app"
```

The checker reports configuration files, Graphify availability, graph statistics, and watcher state. It does not modify the project.

## Editor setup

After installation, restart the editor or refresh its MCP list:

- **Codex:** open the project and inspect `/mcp` or MCP settings.
- **Cursor:** open **Customize → MCPs**.
- **Antigravity:** open **Settings → Customizations → Installed MCP Servers**, then refresh.

## Automation

The installer creates a uniquely named scheduled task based on the normalized project path. It starts at user logon, runs on battery power, prevents duplicate instances, and restarts after transient failures. Graphify's Git hooks cover commits and branch switches.

## Troubleshooting

### Graphify executable is locked

Close Codex, Cursor, and Antigravity, then run the installer again. An active MCP process can hold the executable during package repair.

### Laravel Boost is missing

The Graphify setup still completes. Install the project's Composer dependencies and a compatible PHP version, then rerun the installer.

### MCP server does not appear

Validate the setup with `CHECK_STATUS.bat`, refresh the editor's MCP list, and restart the editor. For Antigravity, confirm that the user-level `.gemini/config/mcp_config.json` exists.

### Graph looks stale

Check that the watcher is running. You can also run `graphify update .` inside the project.
