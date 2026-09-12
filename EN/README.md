# AI Context Bootstrap for Windows

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)](https://www.microsoft.com/windows)

One-command, project-scoped setup for **Codex local clients**, **Codex Cloud**, **Cursor**, and **Google Antigravity**. It builds a local Graphify code graph, connects supported MCP clients, filters noisy files, and keeps the graph current automatically.

> This project reduces avoidable context usage. It cannot guarantee a fixed token reduction because usage depends on the model, task, chat history, and enabled tools.

## Features

- Installs the official `graphifyy` package in an isolated `uv` environment.
- Builds a local, code-only AST graph without sending source code to a cloud model.
- Configures Graphify MCP for Codex, Cursor, and Antigravity.
- Detects Laravel Boost and a compatible PHP executable when available.
- Preserves existing JSON configuration and updates only managed MCP entries.
- Excludes secrets, dependency trees, generated assets, dumps, and logs.
- Keeps the graph current with Git hooks and a per-project Windows watcher.
- Uses stable managed markers, so running the installer again repairs the setup without duplicating rules.
- Provides a read-only status checker.
- Generates Linux setup, maintenance, and token-limited query helpers for Codex Cloud.

## Quick start

1. Download and extract the latest release ZIP.
2. Drag your project folder onto `INSTALL.bat`.
3. Choose **Minimal** for the smallest MCP tool context.
4. Restart your AI editor or refresh its MCP list.
5. Drag the same project onto `CHECK_STATUS.bat` to verify the installation.
6. Commit the generated `.codex/cloud` directory when the repository will be used with Codex Cloud.

For Codex Cloud, set the environment scripts to:

```bash
bash .codex/cloud/setup.sh
bash .codex/cloud/maintenance.sh
```

The second command belongs in the optional maintenance-script field. See the [Codex Cloud section](GUIDE.md#codex-cloud) for details.

PowerShell usage:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app"
```

Optional switches:

```powershell
-SkipLaravelBoost  # Do not configure Laravel Boost
-NoWatcher         # Do not create the Windows logon watcher
```

## Context profiles

| Profile | Enabled scope | Best for |
|---|---|---|
| Minimal | Five core Graphify tools | Lowest MCP catalog overhead; default and recommended |
| Balanced | Architectural Graphify tools and Laravel Boost | Laravel implementation and architecture work |
| Full | All Graphify tools and Laravel Boost | PR analysis and sessions requiring every capability |

Cursor stores individual tool toggles in its UI. For the smallest context, disable unused tools under **Customize → MCPs**; disabled tools are not loaded into Agent context.

## What changes in the target project

The installer may create or update:

```text
.agents/mcp_config.json
.agents/rules/efficient-context.md
.codex/config.toml
.cursor/mcp.json
.cursorignore
.graphifyignore
.gitattributes
.gitignore
.mcp.json
AGENTS.md
graphify-out/graph.json
.codex/cloud/setup.sh
.codex/cloud/maintenance.sh
.codex/cloud/query.sh
```

Existing MCP JSON objects are merged. The Codex and AGENTS sections use explicit managed markers. Review changes before committing them.

## Privacy and security

Code extraction uses Graphify's local tree-sitter AST pipeline with `--code-only`. The ignore rules exclude common secret and generated-file paths. Ignore files are a context optimization and are not a complete security boundary. Never commit credentials.

The installer downloads `uv` through WinGet and installs `graphifyy` from PyPI. Review [SECURITY.md](../SECURITY.md) before use in managed or regulated environments.

## Documentation

- [English guide](GUIDE.md)
- [Türkçe](../TR/README.md)
- [Türkçe kullanım kılavuzu](../TR/GUIDE.md)
- [Agent-driven installation prompt](AGENT_PROMPT.md)
- [Contributing](../CONTRIBUTING.md)

## Platform support

The automated installer currently supports Windows 10 and Windows 11. Pull requests for macOS and Linux installers are welcome.

## License

MIT. Graphify and the supported editors retain their own licenses and trademarks.
