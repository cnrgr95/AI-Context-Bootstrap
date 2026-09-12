# Codex Cloud environment

Commit the generated `.codex/cloud` directory to the target repository. The Windows installer adds focused `.gitignore` exceptions so this directory remains trackable while machine-specific `.codex/config.toml` can stay ignored. In the Codex Cloud environment settings, use:

```bash
# Setup script
bash .codex/cloud/setup.sh

# Maintenance script
bash .codex/cloud/maintenance.sh
```

The setup script installs Graphify during the network-enabled setup phase and builds a local code-only graph. The maintenance script refreshes that graph when a cached environment resumes. The query helper limits output to 800 tokens by default:

```bash
bash .codex/cloud/query.sh "Which modules handle authentication?"
```

Set `AI_CONTEXT_PROFILE` to `Minimal`, `Balanced`, or `Full` in the Codex Cloud environment when you want to override the profile chosen by the Windows installer. No secret is required for code-only extraction.

These scripts do not create a long-running watcher because each cloud task runs in an isolated container. They also do not copy Windows-specific MCP executable paths into the cloud container.

References: [Codex Cloud environments](https://learn.chatgpt.com/docs/environments/cloud-environment), [Codex agent internet access](https://learn.chatgpt.com/docs/cloud/internet-access), and [AGENTS.md instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
