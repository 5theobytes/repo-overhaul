# Repo Overhaul Toolkit

Sub-agents and templates for converting **any** repository into a "trushny-dev"
GitHub presence — README, LICENSE, `.github/*`, CI/CD, linters, hooks, release
flow, and AI-tooling discoverability.

## Source of truth

All sub-agents in this directory derive their behavior from a two-level
documentation stack:

1. **[`SPEC.md`](./SPEC.md)** — curated decisions, the 24-point checklist,
   default tools, placeholder rules, idempotency contract. **Every sub-agent
   reads this before acting.** When SPEC.md and the research doc disagree,
   SPEC wins.
2. **[`docs/research/github-best-practices.md`](../../../docs/research/github-best-practices.md)**
   — raw evidence: 23-repo survey, frequencies, counter-examples. Sub-agents
   consult it only for edge cases not covered by SPEC, and propose SPEC updates
   rather than acting on raw research.

## Sub-agents

| Agent | Role |
|---|---|
| [repo-auditor](./repo-auditor.md) | Read-only audit → produces a 24-point checklist score. Run this first. |
| [readme-rewriter](./readme-rewriter.md) | Generate / upgrade README with hero, badges, sections. |
| [ci-architect](./ci-architect.md) | Set up GitHub Actions tailored to detected stack. |
| [github-templates-installer](./github-templates-installer.md) | Install issue + PR templates. |
| [license-applier](./license-applier.md) | Add LICENSE (MIT by default). |
| [contributing-writer](./contributing-writer.md) | Write CONTRIBUTING.md + CODE_OF_CONDUCT.md. |
| [security-policy-writer](./security-policy-writer.md) | Write SECURITY.md with safe disclosure channel. |
| [linter-setup](./linter-setup.md) | Configure ESLint+Prettier / Biome / Ruff / clippy. |
| [pre-commit-setup](./pre-commit-setup.md) | Husky + lint-staged or pre-commit framework. |
| [changelog-bootstrapper](./changelog-bootstrapper.md) | Release Please OR Changesets OR manual Keep a Changelog. |
| [badge-applier](./badge-applier.md) | Standard badge row in README. |

## How to use

### Primary path — Claude Code slash-command

```
/overhaul-repo                  # full interactive pipeline (audit → fix → re-audit)
/overhaul-repo --dry-run        # just audit, no writes
/overhaul-repo --yes            # auto-accept all stages
```

The `/overhaul-repo` command lives at
[`.claude/commands/overhaul-repo.md`](../../commands/overhaul-repo.md). It calls
each sub-agent in dependency order, asks for confirmation before writes, and
re-runs the auditor at the end to show the delta.

### Calling a single sub-agent

When you know exactly what's missing — bypass the orchestrator:

```
/agent repo-auditor             # just score the current state
/agent readme-rewriter          # rewrite README only
/agent ci-architect             # add CI only
/agent linter-setup             # configure Biome/ESLint/Ruff
```

### Fallback — shell installer (no AI required)

If you don't have Claude Code available (CI job, container build, quick
scaffold), use the shell installer for **mechanical** template copying with
placeholder substitution:

```
bash scripts/repo-overhaul/install.sh     # macOS / Linux / WSL
pwsh scripts/repo-overhaul/install.ps1    # Windows
```

The shell installer skips the AI reasoning — it doesn't read your code, doesn't
pick the right linter for your stack, and doesn't generate a README from your
package.json. It just `sed`-substitutes `{{PROJECT_NAME}}` / `{{AUTHOR}}` /
`{{LICENSE}}` / `{{YEAR}}` into the templates. Use it when:

- You're running in CI and there's no Claude Code session.
- You want deterministic, replayable scaffolding (same input → same output).
- You just need the boilerplate quickly and will polish manually.

For everything else, use `/overhaul-repo`.

## Comparison

| Need | Use |
|---|---|
| First-time scaffold with awareness of your code | `/overhaul-repo` |
| Re-run after some manual changes — keep what's good | `/overhaul-repo` |
| Generate README based on your actual `package.json` / source | `/agent readme-rewriter` |
| Pick Biome vs ESLint based on existing tooling | `/agent linter-setup` |
| CI pipeline that bootstraps a fresh repo | `install.sh` / `install.ps1` |
| Just want the boilerplate, will tune later | `install.sh` / `install.ps1` |

## Idempotency

Every sub-agent:

- Checks for existing files before writing.
- Diffs and asks before overwriting non-trivial content.
- Writes once per run — re-running is safe.

## Adding a new sub-agent

1. Drop a new `.md` file in this directory with YAML frontmatter:
   ```yaml
   ---
   name: my-agent
   description: One-line description. Use when ...
   tools: Read, Write, Edit, Bash, Glob, Grep
   ---
   ```
2. Body = system-prompt-style instructions: goal, inputs, steps, output, rules.
3. List it in this README.
