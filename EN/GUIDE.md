# User guide

## Requirements

- Windows 10/11, a current Linux distribution, or macOS
- Git
- Windows: WinGet and PowerShell 5.1+
- Linux/macOS: Bash, curl, and Python 3.10+
- Internet access during first installation
- Write access to the target repository

## Install or repair

Drag a project directory onto `Windows/EN/INSTALL.bat`, or run:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app"
```

Choose a context profile explicitly when needed:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app" -ContextProfile Minimal
```

`Minimal` exposes five core Graphify tools and removes installer-managed Laravel Boost entries. `Balanced` adds architectural graph tools and Laravel Boost. `Full` exposes the complete Graphify tool set and Laravel Boost. Balanced and Full also build local graph communities without an LLM.

The operation is designed to be repeatable. It merges MCP JSON configuration and replaces only its marked Codex and AGENTS sections.

### Linux and macOS

```bash
bash Linux/EN/INSTALL.sh /path/to/project
# On macOS:
bash macOS/EN/INSTALL.sh /path/to/project
# Direct, non-interactive form:
bash setup-ai-context.sh /path/to/project --profile Minimal
```

Use `--skip-laravel-boost` or `--no-watcher` when needed. Linux uses a systemd user service when available; macOS uses a LaunchAgent. Git hooks remain active if a background service cannot be installed.

## Verify

Drag the project directory onto `Windows/EN/CHECK_STATUS.bat`, or run:

```powershell
powershell -ExecutionPolicy Bypass -File ..\check-status.ps1 -ProjectPath "C:\projects\my-app"
```

Linux/macOS:

```bash
bash Linux/EN/CHECK_STATUS.sh /path/to/project
# On macOS:
bash macOS/EN/CHECK_STATUS.sh /path/to/project
```

The checker reports configuration files, Graphify availability, graph statistics, and watcher state. It does not modify the project.

## Editor setup

After installation, restart the editor or refresh its MCP list:

- **Codex:** open the project and inspect `/mcp` or MCP settings.
- **Cursor:** open **Customize → MCPs**.
- **Antigravity:** open **Settings → Customizations → Installed MCP Servers**, then refresh.

## Automation

The installer creates a uniquely named scheduled task based on the normalized project path. It starts at user logon, runs on battery power, prevents duplicate instances, and restarts after transient failures. Graphify's Git hooks cover commits and branch switches.

## Codex Cloud

The installer writes `.codex/cloud/setup.sh`, `maintenance.sh`, `query.sh`, and a short README into the target repository. Commit these files, then configure the repository's Codex Cloud environment:

```bash
# Setup script
bash .codex/cloud/setup.sh

# Maintenance script
bash .codex/cloud/maintenance.sh
```

The setup phase installs Graphify and builds a code-only graph. The maintenance phase refreshes it when Codex resumes a cached container. Cloud tasks do not use the Windows watcher or Windows executable paths.

For cross-module questions when a local MCP server is unavailable, the generated `AGENTS.md` tells Codex to run:

```bash
bash .codex/cloud/query.sh "Which modules handle authentication?"
```

The helper caps output at 800 tokens by default. Pass a second numeric argument only when the task needs a larger result. You can override the selected profile with the `AI_CONTEXT_PROFILE` environment variable.

## Troubleshooting

### Graphify executable is locked

Close Codex, Cursor, and Antigravity, then run the installer again. An active MCP process can hold the executable during package repair.

### Laravel Boost is missing

The Graphify setup still completes. Install the project's Composer dependencies and a compatible PHP version, then rerun the installer.

### MCP server does not appear

Validate the setup with `Windows/EN/CHECK_STATUS.bat`, refresh the editor's MCP list, and restart the editor. For Antigravity, confirm that the user-level `.gemini/config/mcp_config.json` exists.

### Graph looks stale

Check that the watcher is running. You can also run `graphify update .` inside the project.
