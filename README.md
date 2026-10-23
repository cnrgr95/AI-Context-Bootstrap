# AI Context Bootstrap

[![CI](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Focused, local code context for Codex, Cursor, Google Antigravity / Gemini, and Codex Cloud.**

AI Context Bootstrap indexes a selected repository with [Graphify](https://pypi.org/project/graphifyy/) and configures the supported Model Context Protocol (MCP) clients. Its **Minimal** profile advertises fewer tools, while **Balanced** and **Full** expand the available capabilities. The goal is to make codebase exploration more focused; **token savings vary by project and task and are not guaranteed**.

**[Türkçe hızlı başlangıç](#türkçe-hızlı-başlangıç)** · [Installation](#installation) · [Security](#security-and-safety) · [Tests](#verification-and-tests)

## Choose your package

Each folder contains a **self-contained** installer, status checker, setup script, guide, security notes, and agent prompt.

| Language | Windows | Linux | macOS |
| --- | --- | --- | --- |
| English | [EN/Windows](EN/Windows/README.md) | [EN/Linux](EN/Linux/README.md) | [EN/macOS](EN/macOS/README.md) |
| Türkçe | [TR/Windows](TR/Windows/README.md) | [TR/Linux](TR/Linux/README.md) | [TR/macOS](TR/macOS/README.md) |

## Features

- **Local code graph:** Graphify extracts a repository graph using `--code-only` into `graphify-out/`.
- **Editor integration:** project-scoped MCP configuration for Codex, Cursor, and Google Antigravity / Gemini.
- **Tool profiles:** Minimal **5**, Balanced **7**, and Full **10** Graphify tools, filtered by a stdio MCP proxy. Profiles are limits on the tool interface, **not** operating-system permissions.
- **Trusted proxy location:** the executable Python MCP proxy runs from a user-specific installation directory **outside the source repository**, helping keep project file edits separate from the executable integration.
- **Safer repeated setup:** existing unrelated MCP entries are preserved; name collisions are rejected; tracked configuration files are backed up and restored if setup fails.
- **Opt-in integrations:** Laravel Boost, Git hooks, and continuous background watchers are **off by default**.
- **Codex Cloud helpers:** generated setup, maintenance, and graph query scripts; the query helper defaults to an **800-token budget** (configurable within validated limits).
- **Bilingual / cross-platform:** English and Turkish packages for Windows, Linux, and macOS.

## Requirements

| System | Requirements |
| --- | --- |
| Windows | Windows 10/11, PowerShell 5.1+, Git, WinGet or existing `uv`, initial internet access |
| Linux | Git, Bash, Python 3.10+, `curl` (for first-time `uv` installation), initial internet access |
| macOS | Git, Bash, Python 3.10+, `curl` (for first-time `uv` installation), initial internet access |

All systems require write access to the **target project directory**. Laravel Boost is optional and requires a compatible project with PHP/Composer. New Graphify installations use the tested `graphifyy==0.9.94` release; **existing Graphify installations are not automatically replaced**.

## Installation

Download or clone the repository, then choose the folder for your language and operating system. Run the installer against **your own target project's path**, not the AI Context Bootstrap repository.

### Windows (PowerShell)

```powershell
cd EN/Windows
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath "C:\projects\my-app" -ContextProfile Minimal
```

Or run `EN/Windows/INSTALL.bat` for the interactive installer (you can also drag a project folder onto it).

### Linux

```bash
cd EN/Linux
bash setup-ai-context.sh /absolute/path/to/my-app --profile Minimal
```

### macOS

```bash
cd EN/macOS
bash setup-ai-context.sh /absolute/path/to/my-app --profile Minimal
```

To choose a larger profile, replace `Minimal` with `Balanced` or `Full`.

### Optional integrations

These features are not enabled automatically:

| Feature | Windows PowerShell flag | Linux / macOS flag |
| --- | --- | --- |
| Laravel Boost | `-EnableLaravelBoost` | `--enable-laravel-boost` |
| Git hooks | `-EnableHooks` | `--enable-hooks` |
| Background watcher | `-EnableWatcher` | `--enable-watcher` |

**Caution:** Laravel Boost can execute application code (including Artisan commands). Enable optional features only in trusted, reviewed repositories. Boost requires a compatible PHP project and a non-Minimal profile.

## Verify your installation

```powershell
# Windows, from EN/Windows
powershell.exe -NoProfile -File .\check-status.ps1 -ProjectPath "C:\projects\my-app"
```

```bash
# Linux/macOS, from EN/Linux or EN/macOS
bash check-status.sh /absolute/path/to/my-app
```

You can also use `CHECK_STATUS.bat` or `CHECK_STATUS.sh` in the selected package. Refresh the editor's MCP server list or restart the editor after setup.

The status check covers the expected graph, project configurations, trusted proxy, and installed Graphify executable. A green local status check alone does **not** prove every GUI integration works.

## Codex Cloud

The installer prepares `.codex/cloud/setup.sh`, `maintenance.sh`, and `query.sh` within the **target repository**. Commit the cloud scripts if you intend to use them, then manually configure the setup and maintenance commands in your Codex Cloud environment. A local installer cannot change your remote Codex account settings.

Example graph query:

```bash
bash .codex/cloud/query.sh "Which modules use this function?" 800
```

See your package's [guide](EN/Linux/GUIDE.md) for detailed instructions.

## Security and safety

- **Tool allowlisting:** the proxy filters MCP `tools/list` and `tools/call`, rejects other client-side MCP request methods by default, and refuses cross-project `project_path` values.
- **Bounded protocol input:** overly large MCP messages and excessive pending tool-list requests are rejected.
- **Config preservation:** installers avoid overwriting unrelated MCP servers and restore **tracked configuration files** after a failed setup.
- **Sensitive files:** generated ignore patterns reduce accidental indexing of secrets, credentials, dependencies, and generated output. **Ignore patterns are not access controls.**
- **Trusted executable:** the MCP proxy is installed under the user's local data directory rather than being executed from the project tree.

**Limits:** This is **not an OS sandbox**. The host editor, Graphify process, and optional integrations still inherit their actual system permissions. Rollback does **not** revert installed packages, generated graph data, registered services, or Git hooks. Previously installed watchers/hooks are not automatically removed. Review the scripts before running them on unfamiliar repositories.

Read the full [security policy](SECURITY.md), [installation guides](EN/Linux/GUIDE.md), and [changelog](CHANGELOG.md).

## Verification and tests

GitHub Actions checks:

- PowerShell syntax and Python MCP proxy unit tests on Windows;
- Bash syntax, installer smoke tests, simulated installation failures, configuration rollback, and MCP collisions on Ubuntu/macOS;
- a **real Graphify 0.9.94** graph-extraction + MCP stdio integration test on **Windows, Ubuntu, and macOS**;
- parity of the six distribution packages and basic sensitive-content checks.

View the latest results in [GitHub Actions](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml).

**Test scope:** The CI suite does not constitute complete end-to-end UI tests for Codex, Cursor, or Antigravity, nor a fully interactive Windows installer test. Performance or token-reduction percentages have not been established by production benchmarks.

## Türkçe hızlı başlangıç

AI Context Bootstrap; **Codex, Cursor, Google Antigravity / Gemini ve Codex Cloud** için proje kodundan yerel bir Graphify grafı oluşturur ve MCP bağlantılarını hazırlar. Türkçe paketler [TR/Windows](TR/Windows/README.md), [TR/Linux](TR/Linux/README.md) ve [TR/macOS](TR/macOS/README.md) klasörlerindedir.

1. İşletim sisteminize uygun **TR** klasörünü açın.
2. `INSTALL.bat` (Windows) veya `INSTALL.sh` (Linux/macOS) ile hedef proje klasörünü seçin.
3. Varsayılan **Minimal (5 araç)** profilini kullanın. Balanced (7) veya Full (10) gerektiğinde seçilebilir.
4. Laravel Boost, Git hook ve watcher özelliklerini sadece ihtiyaç varsa açıkça etkinleştirin.
5. `CHECK_STATUS.bat` veya `CHECK_STATUS.sh` ile kurulum durumunu kontrol edin.

Kurulum sırasında mevcut MCP yapılandırmaları korunmaya çalışılır; hata olursa izlenen yapılandırma dosyaları geri yüklenir. **Tüm sistemin geri alınması veya sıfır hata garantisi yoktur.** Ayrıntılar için ilgili [Türkçe kılavuza](TR/Windows/GUIDE.md) ve [güvenlik belgesine](SECURITY.md) bakın.

## License

MIT. See [LICENSE](LICENSE).
