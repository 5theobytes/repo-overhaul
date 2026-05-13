# scripts/repo-overhaul

Shell-based orchestrators for the
[repo-overhaul toolkit](../../.claude/agents/repo-overhaul/). They wrap the
Claude Code sub-agents into one-command scaffolding for any new or existing
repository.

## Files

| File | Platform | Purpose |
|---|---|---|
| `install.sh` | macOS / Linux / WSL / Git Bash | Detect stack, prompt for metadata, copy templates with placeholder substitution. |
| `install.ps1` | Windows PowerShell 5.1+ / pwsh 7+ | Same as `install.sh`. |
| `detect-stack.sh` | POSIX | Print detected stack name (`node` / `python` / `rust` / `go` / `mixed` / `unknown`). |

## Quickstart

From the repo you want to overhaul:

```bash
# macOS / Linux / WSL
bash /path/to/repo-overhaul/scripts/repo-overhaul/install.sh

# Windows
pwsh C:\path\to\repo-overhaul\scripts\repo-overhaul\install.ps1
```

The script will:

1. Detect your stack (Node / Python / Rust / Go).
2. Prompt for project name, author, and license (defaults to MIT).
3. Copy every applicable template from
   [`templates/repo-overhaul/`](../../templates/repo-overhaul/) with placeholders
   filled in.
4. Skip any file that already exists (idempotent — safe to re-run).
5. Print a punch-list of manual follow-ups (CODEOWNERS, secrets, etc.).

## What gets created

```
<repo-root>/
├── LICENSE
├── README.md                 ← only if missing
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── .editorconfig
├── .gitattributes
├── .nvmrc                    ← node stack only
├── .prettierrc.json          ← node stack only
└── .github/
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.yml
    │   ├── feature_request.yml
    │   └── config.yml
    ├── PULL_REQUEST_TEMPLATE.md
    ├── dependabot.yml
    ├── FUNDING.yml
    ├── CODEOWNERS
    └── workflows/
        ├── ci.yml            ← ci-node.yml or ci-python.yml
        └── release-please.yml
```

## Going deeper (sub-agents)

For tasks that need code-aware reasoning — rewriting a complex README, picking
the right linter for a mixed project, generating accurate badges — invoke the
matching sub-agent from Claude Code:

```
/agent repo-auditor                ← score current state
/agent readme-rewriter             ← generate README based on repo content
/agent linter-setup                ← pick Biome vs ESLint+Prettier vs Ruff
/agent ci-architect                ← matrix workflow tailored to stack
/agent changelog-bootstrapper      ← Release Please vs Changesets
```

See [`.claude/agents/repo-overhaul/README.md`](../../.claude/agents/repo-overhaul/README.md)
for the full list.

## Testing the toolkit

```bash
# Create a throwaway repo
mkdir /tmp/test-repo && cd /tmp/test-repo
git init
echo '{"name":"test","version":"0.1.0"}' > package.json

# Run the installer
bash /path/to/repo-overhaul/scripts/repo-overhaul/install.sh

# Verify
ls -la
ls -la .github/

# Re-run — should skip everything
bash /path/to/repo-overhaul/scripts/repo-overhaul/install.sh
```
