# Linux user guide

## Requirements

Git, Bash, Python 3.10+, curl, internet access for first installation. Write access to the target project is required. Laravel Boost is optional and requires a working PHP/Composer installation.

## Install and repair

Run `bash INSTALL.sh /absolute/path/to/project` from this folder. The installer is repeatable and merges MCP JSON settings. For non-interactive use:

```bash
bash setup-ai-context.sh /absolute/path/to/project --profile Minimal
```

Minimal enables five core Graphify tools. Balanced adds architecture tools; Laravel Boost is enabled only through explicit opt-in. Full enables all Graphify tools. The graph is built locally with `--code-only`; no API key is needed for extraction.

## Files and automation

The installer creates project-scoped Codex, Cursor, and Antigravity MCP configuration, short agent rules, `.graphifyignore`, Git hooks, and a systemd user service (when available). It also creates `.codex/cloud/setup.sh`, `maintenance.sh`, and `query.sh` for Codex Cloud. Commit the cloud scripts to your target repository, then enter `bash .codex/cloud/setup.sh` and `bash .codex/cloud/maintenance.sh` in that repository's Codex Cloud environment settings.

The cloud query helper defaults to an 800-token output budget. Cloud environment settings must be configured in Codex; a local installer cannot change a remote account setting.

## Check and troubleshoot

Run `bash CHECK_STATUS.sh /absolute/path/to/project`. The checker reports MCP files, graph, and tool availability. If MCP tools are absent, refresh the editor's MCP list or restart it. If Laravel Boost is absent, install project dependencies and a compatible PHP version, then rerun the installer. If the graph is stale, run `graphify update .` inside the project.

Token savings depend on the task and model; no fixed reduction is guaranteed. See [security guidance](SECURITY.md).

## MCP tool permissions and scope

The installer creates a project-scoped `.codex/graphify-mcp-proxy.py` filter. Minimal (5), Balanced (7) and Full (10) are enforced at MCP `tools/list` and `tools/call` for Codex, Cursor and Antigravity/Gemini. Graphify's `project_path` cannot target another project. This filter is **not an operating-system sandbox**; restrict Graphify's process permissions and the AI agent's file/terminal permissions separately. Re-run setup to change profiles.

## Secure setup options

Laravel Boost and Git hook installation are **off by default**. Boost can execute project code through Artisan and may reach the application's database. Explicitly enable it only in trusted projects: Windows `-EnableLaravelBoost -EnableHooks`; Linux/macOS `--enable-laravel-boost --enable-hooks`. Existing Laravel Boost MCP entries are preserved on ordinary reinstalls. Background watching is off by default; opt in with Windows `-EnableWatcher` or Linux/macOS `--enable-watcher`. MCP profile filtering is not an OS security boundary.

## Setup recovery

Tracked MCP, Codex, Gemini and agent configuration files are backed up before setup changes and restored if setup fails. External package installs, graph output and existing services remain outside the transaction. Unmanaged MCP server collisions fail without overwriting the user's existing entry. Setup never silently uninstalls a user-owned Boost connection.
