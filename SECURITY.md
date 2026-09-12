# Security policy

## Reporting a vulnerability

Please report security issues privately through GitHub Security Advisories. Do not open a public issue containing exploit details, credentials, or private source code.

## Security model

The installer executes local package-manager commands and updates configuration in a user-selected repository. Review the scripts before running them. Use releases from the canonical repository and verify release checksums when provided.

The generated ignore files reduce accidental context inclusion but are not access-control boundaries. MCP clients and terminal tools may still access files according to their own permissions. Keep secrets outside repositories and use operating-system permissions and secret managers.

Supported security updates apply to the latest release.

Codex Cloud installs Graphify during the environment setup phase. Keep agent-phase internet access disabled unless the project requires it. When access is required, use the narrowest domain and HTTP-method allowlist that supports the task.
