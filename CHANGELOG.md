# Changelog

All notable changes follow semantic versioning.

## 2.1.0 - 2026-09-12

- Organized entry points into separate Windows, Linux, and macOS folders, each with English and Turkish options.
- Made the root README English and added a clear platform/language selection table.
- Updated launchers, guides, and smoke tests for the new paths.

## 2.0.0 - 2026-09-12

- Added native Linux and macOS installation and status scripts.
- Added localized Unix launchers under both `EN` and `TR`.
- Added Linux systemd user watchers and macOS LaunchAgents with Git-hook fallback.
- Added Ubuntu and macOS CI syntax validation.
- Preserved the same Minimal, Balanced, and Full profiles across all supported platforms.

## 1.3.0 - 2026-09-12

- Added Codex Cloud setup, maintenance, and token-limited Graphify query scripts.
- Made the Windows installer generate a project-scoped .codex/cloud bundle automatically.
- Added Codex Cloud readiness to the status report and agent guidance.
- Documented the required Codex Cloud environment settings in Turkish and English.

## 1.2.0 - 2026-09-12

- Separated all Turkish and English user-facing files into `TR` and `EN` directories.
- Added a language-neutral root landing page and localized status checkers.
- Updated localized installers so they call the shared automation engine from their subdirectories.

## 1.1.0 - 2026-09-12

- Added complete English and Turkish entry points and documentation.
- Added Minimal, Balanced, and Full context profiles.
- Reduced the default Codex and Antigravity MCP tool catalog to five core Graphify tools.
- Prevented duplicate Antigravity tool catalogs with project-specific server identifiers.
- Added English and Turkish one-click installers.

## 1.0.0 - 2026-09-12

- Added repeatable Graphify MCP setup for Codex, Cursor, and Antigravity.
- Added optional Laravel Boost detection.
- Added automatic Git-hook and Windows watcher setup.
- Added secret/generated-file context filters.
- Added status checker, bilingual documentation, CI, and public repository metadata.
