# Contributing

Thank you for improving AI Context Bootstrap.

1. Open an issue for significant behavior changes.
2. Create a focused branch and keep changes portable; never commit machine-specific paths or credentials.
3. Parse all PowerShell scripts before submitting:

   ```powershell
   $errors = $null
   [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\setup-ai-context.ps1), [ref]$null, [ref]$errors) | Out-Null
   if ($errors) { $errors; exit 1 }
   ```

4. Test installation twice against a disposable Git repository to verify idempotency.
5. Explain target-project changes, verification, and platform limitations in the pull request.

Do not include API keys, real `.env` files, database dumps, personal paths, or generated graphs from private repositories.
