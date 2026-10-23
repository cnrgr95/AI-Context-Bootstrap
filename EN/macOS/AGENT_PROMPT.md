```text
Set up focused project context for Codex, Codex Cloud, Cursor, and Google Antigravity on macOS.
Target project: <ABSOLUTE_PROJECT_PATH>

1. Preserve existing project changes and unrelated MCP servers. Merge configuration and keep the setup repeatable.
2. Install Graphify in an isolated environment, build a local code-only graph, and exclude secrets, dependencies, dumps, and generated files.
3. Configure project-scoped MCP for Codex, Cursor, and Antigravity. Use the Minimal profile by default; expose more tools only when the task requires them.
4. Configure Laravel Boost only with explicit user opt-in, a compatible PHP runtime and a trusted project. Never implicitly remove existing connections.
5. Install Git hooks and background watchers only on explicit request. Generate safe Codex Cloud setup, maintenance and 800-token query helpers.
6. Roll back tracked configurations on failure, validate MCP and graph behavior, and avoid fixed token-saving claims.
```
