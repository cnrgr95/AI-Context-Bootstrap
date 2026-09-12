# AI Context Bootstrap

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml/badge.svg)](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml)

Set up focused Graphify context for Codex, Codex Cloud, Cursor, and Google Antigravity. Choose your operating system, then your language:

| Platform | English | Türkçe |
|---|---|---|
| Windows 10/11 | [Windows/EN](Windows/EN/README.md) | [Windows/TR](Windows/TR/README.md) |
| Linux | [Linux/EN](Linux/EN/README.md) | [Linux/TR](Linux/TR/README.md) |
| macOS | [macOS/EN](macOS/EN/README.md) | [macOS/TR](macOS/TR/README.md) |

Each platform/language folder contains an installer, a status checker, and a short README. Shared setup engines live at the repository root. For complete documentation, see the [English guide](EN/GUIDE.md) or [Turkish guide](TR/GUIDE.md).

The default **Minimal** profile keeps the MCP tool catalog small. **Balanced** and **Full** are available when a task needs more tools. Token savings vary by project and task; no fixed percentage is guaranteed.

## Quick start

1. Download and extract the latest ZIP.
2. Open the folder for your operating system and language.
3. Run its installer with the path to your project. Choose **Minimal** unless you need the other profiles.
4. Refresh MCP in your editor and run the status checker.

The installer prepares project-scoped MCP configuration, a local code-only Graphify graph, focused context rules, Git hooks, an OS-specific watcher, and Codex Cloud scripts. Review generated files before committing them.

## Requirements

Git is required on all platforms. Windows uses PowerShell and WinGet. Linux and macOS use Bash, Python 3.10+, and curl. The first installation needs internet access.

## Security and license

Read [SECURITY.md](SECURITY.md) before installing. This project is MIT licensed; supported editors and Graphify have their own licenses and trademarks.
