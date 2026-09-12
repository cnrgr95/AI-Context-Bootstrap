```text
Set up and verify project-scoped context and token optimization for Codex, Cursor, and Google Antigravity.

Target project: <ABSOLUTE_PROJECT_PATH>

Requirements:
1. Preserve existing user changes, MCP servers, and configuration. Merge settings instead of replacing whole files.
2. Install the official `graphifyy` package in an isolated environment with MCP and watch extras. Install `uv` first when required on Windows.
3. Index the repository with local AST extraction and `--code-only`. Exclude secrets, `.env*`, keys, dumps, SQL exports, dependencies, build output, generated assets, and storage directories.
4. Connect Graphify MCP to project-scoped Codex, Cursor, and Antigravity configuration. Use the same unique project-specific server name for Antigravity project and user configuration to prevent duplicate tool catalogs.
5. Add idempotent Codex Cloud Linux setup and maintenance scripts under `.codex/cloud`. They must install Graphify during setup, refresh the graph during maintenance, and provide a query helper capped at 800 tokens by default. Do not use Windows paths or a persistent watcher in cloud scripts.
6. Default to a minimal tool profile: `query_graph`, `get_node`, `get_neighbors`, `shortest_path`, and `graph_stats`. Do not expose PR/community tools unless requested.
7. Configure Laravel Boost only when the user selects a balanced/full profile, `boost:mcp` exists, and a compatible PHP executable has been verified.
8. Install Graphify Git hooks and a unique per-project Windows logon watcher. It must prevent duplicate instances, work on battery power, and restart after transient failures.
9. Keep persistent agent rules short. Use Graphify for cross-module dependency questions; use narrow file reads for explicit small tasks; verify graph results against current source.
10. Test MCP initialize, tools/list, graph_stats, and automatic graph refresh. Remove temporary test artifacts.
11. Make the operation repeatable and repair-safe. Do not hardcode usernames or project paths. Do not promise a fixed token-reduction percentage.
```
