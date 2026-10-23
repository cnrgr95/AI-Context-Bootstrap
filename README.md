# AI Context Bootstrap

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml/badge.svg)](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml)

AI Context Bootstrap prepares focused project context for Codex, Codex Cloud, Cursor, and Google Antigravity. It builds a local Graphify code graph, connects supported MCP clients, and can optionally keep the graph current using a user-enabled watcher or Git hooks. The default Minimal profile limits the enabled tool catalog; actual token savings depend on the task.

Choose a language, then your operating system. Every destination is a self-contained package with its own installer, status checker, guide, agent prompt, and setup scripts.

| Language | Linux | Windows | macOS |
|---|---|---|---|
| English | [EN/Linux](EN/Linux/README.md) | [EN/Windows](EN/Windows/README.md) | [EN/macOS](EN/macOS/README.md) |
| Türkçe | [TR/Linux](TR/Linux/README.md) | [TR/Windows](TR/Windows/README.md) | [TR/macOS](TR/macOS/README.md) |

Select your folder and follow its README. Git is required on all platforms. Initial installation needs internet access. Review [security information](SECURITY.md) before running an installer.

## Current security-hardening work

The draft hardening branch adds tool-scoped MCP filtering, a trusted per-user proxy outside project code, explicit permission switches for Boost/hooks/watchers, configuration rollback safeguards and cross-platform test coverage. Fresh installs target the validated Graphify 0.9.94 release. CI includes live stdio integration, but CI success does not certify all editor-specific behavior or remove the need to review scripts before running them. Changes remain under review until merged.
