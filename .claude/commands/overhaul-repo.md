---
description: Run the full repo-overhaul pipeline — audit, then sequentially invoke each sub-agent with user confirmation before writes.
argument-hint: [--dry-run | --yes | --skip <agent>,<agent>]
---

# /overhaul-repo

Orchestrates the repo-overhaul toolkit end-to-end against the current repository.

**Before invoking any sub-agent, read
[`.claude/agents/repo-overhaul/SPEC.md`](../agents/repo-overhaul/SPEC.md)** —
it defines the 24-point checklist, the default tooling per stack, and the
idempotency contract every stage must honor. Reference SPEC sections in your
status messages so the user can audit the reasoning.

## Inputs

- `$ARGUMENTS` — optional flags:
  - `--dry-run` → run `repo-auditor` only, no writes.
  - `--yes` → skip per-agent confirmation (still respect each agent's "skip if exists" logic).
  - `--skip <agent1>,<agent2>` → omit specific stages.

## Pipeline

Execute the following stages sequentially. After each stage, summarise what was
created/changed in 2-3 lines before moving on. Stop if any stage reports a hard
failure.

### Stage 1 — Audit (always)

Invoke the **repo-auditor** sub-agent. Show its 24-point checklist score
(`Score: N/24 (M: x/9, S: y/9, N: z/6)`) and the per-item table. If `--dry-run`,
stop here.

### Stage 2 — Foundational files (Must-have, 9 items)

Run in order; each is a separate sub-agent call:

1. `license-applier` — adds LICENSE if missing.
2. `github-templates-installer` — issue + PR templates.
3. `contributing-writer` — CONTRIBUTING.md + CODE_OF_CONDUCT.md.
4. `security-policy-writer` — SECURITY.md with private disclosure.
5. `ci-architect` — `.github/workflows/ci.yml` tailored to detected stack.
6. `readme-rewriter` — only if README is missing or < 30 lines.
7. `linter-setup` — root linter/formatter config.

### Stage 3 — Should-have layer (run only what auditor marked ✗ or ⚠)

8. `changelog-bootstrapper` — CHANGELOG + release flow.
9. `pre-commit-setup` — husky / pre-commit (ASK FIRST, only 5/23 top repos use it).
10. `badge-applier` — standard badge row in README.

### Stage 4 — Polish

11. Walk the freshly-created files and grep for unfilled `{{...}}` placeholders;
    report them as a punch-list the user must hand-fill.
12. Suggest follow-up actions that need GitHub UI access (Dependabot alerts,
    Discussions, secrets, branch protection).

## Rules

- Always show the auditor output FIRST so the user sees the gap before any writes.
- Before each writing stage, print: `→ Stage X: <agent-name> — <one-line goal>`.
- If `--yes` is not set, ask `Run this stage? [Y/n/skip]` before each writing
  agent.
- Never run two writing agents in parallel — output must be linear and traceable.
- After completion, run the auditor one more time and print the new score for
  comparison.

## When to recommend the shell installer instead

If the user is in CI or wants a non-interactive scaffold of *just* the file
templates (no code-aware rewriting), point them at
`scripts/repo-overhaul/install.sh` / `install.ps1`. The shell installer skips
the AI reasoning and just does placeholder substitution — faster, deterministic,
no Claude Code session required.

## Examples

```
/overhaul-repo                          # interactive, full pipeline
/overhaul-repo --dry-run                # just audit
/overhaul-repo --yes                    # auto-accept every stage
/overhaul-repo --skip pre-commit-setup,badge-applier
```
