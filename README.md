# repo-overhaul

A toolkit that audits any GitHub repository against a 24-point best-practices
checklist and writes the missing files — either through Claude Code sub-agents
(code-aware) or a shell installer (mechanical, no AI).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## What it does

1. **Audits** your repo against 9 must-have, 9 should-have, and 6 nice-to-have
   items: LICENSE, README, CI, issue/PR templates, CONTRIBUTING, SECURITY,
   CODE_OF_CONDUCT, dependabot, runtime pin, linter, pre-commit, changelog,
   release automation, CODEOWNERS, FUNDING, AI-tooling discoverability, etc.
2. **Generates** the missing files tailored to your detected stack
   (TS/JS, Python, Rust, Go) — picking sane defaults (Biome vs ESLint+Prettier,
   Release Please vs Changesets, Dependabot vs Renovate) per
   [`.claude/agents/repo-overhaul/SPEC.md`](.claude/agents/repo-overhaul/SPEC.md).
3. **Idempotent.** Re-running never overwrites substantial content; stub files
   get a diff prompt; everything else is skipped.

The full spec — checklist, decision tree, placeholder rules, idempotency
contract — lives in [`SPEC.md`](.claude/agents/repo-overhaul/SPEC.md). The
evidence base (a 23-repo survey of top GitHub projects) is in
[`docs/research/github-best-practices.md`](docs/research/github-best-practices.md).

## Install

### Option A — Claude Code (recommended)

```bash
# 1. Clone the toolkit
git clone https://github.com/5theobytes/repo-overhaul.git ~/repo-overhaul

# 2. Copy the four toolkit directories into your target repo
cd /path/to/your/target-repo
cp -r ~/repo-overhaul/.claude .
cp -r ~/repo-overhaul/templates .
cp -r ~/repo-overhaul/scripts .
cp -r ~/repo-overhaul/docs/research docs/  # optional, for evidence trail

# 3. Open the target repo in Claude Code and run
/overhaul-repo
```

Alternative: symlink instead of copy so updates to the toolkit propagate
automatically.

```bash
# Windows (run as admin for junctions)
cmd /c mklink /J .claude\agents\repo-overhaul ~\repo-overhaul\.claude\agents\repo-overhaul
cmd /c mklink /J templates\repo-overhaul     ~\repo-overhaul\templates\repo-overhaul
cmd /c mklink /J scripts\repo-overhaul       ~\repo-overhaul\scripts\repo-overhaul

# macOS / Linux
ln -s ~/repo-overhaul/.claude/agents/repo-overhaul .claude/agents/repo-overhaul
ln -s ~/repo-overhaul/templates/repo-overhaul      templates/repo-overhaul
ln -s ~/repo-overhaul/scripts/repo-overhaul        scripts/repo-overhaul
```

### Option B — Shell installer (no AI)

For CI builds, containers, or quick scaffolding when Claude Code isn't
available. Mechanical template copying with placeholder substitution
(`{{PROJECT_NAME}}`, `{{AUTHOR}}`, `{{LICENSE}}`, `{{YEAR}}`).

```bash
# macOS / Linux / WSL
bash scripts/repo-overhaul/install.sh /path/to/target-repo

# Windows
pwsh scripts/repo-overhaul/install.ps1 -TargetRepo C:\path\to\target-repo
```

The shell installer doesn't read your code, doesn't pick the right linter,
and doesn't write a stack-aware README. For that, use Option A.

## Usage

```
/overhaul-repo                        # interactive: audit → confirm → fix → re-audit
/overhaul-repo --dry-run              # audit only, no writes
/overhaul-repo --yes                  # auto-accept every stage
/overhaul-repo --skip pre-commit-setup,badge-applier
```

The orchestrator lives at
[`.claude/commands/overhaul-repo.md`](.claude/commands/overhaul-repo.md). It
runs each sub-agent in dependency order with confirmation prompts before each
writing step.

## Sub-agents

Drop into a single one when you know what's missing:

| Agent | Role |
|---|---|
| [repo-auditor](.claude/agents/repo-overhaul/repo-auditor.md) | Score the current state against the 24-point checklist (read-only) |
| [license-applier](.claude/agents/repo-overhaul/license-applier.md) | Add `LICENSE` (MIT default; Apache-2.0 / dual-MIT-Apache for Rust) |
| [github-templates-installer](.claude/agents/repo-overhaul/github-templates-installer.md) | Issue + PR templates, FUNDING, CODEOWNERS, `.editorconfig` |
| [contributing-writer](.claude/agents/repo-overhaul/contributing-writer.md) | `CONTRIBUTING.md` + Contributor Covenant v2.1 |
| [security-policy-writer](.claude/agents/repo-overhaul/security-policy-writer.md) | `SECURITY.md` with private disclosure channel |
| [ci-architect](.claude/agents/repo-overhaul/ci-architect.md) | GitHub Actions tailored to detected stack |
| [readme-rewriter](.claude/agents/repo-overhaul/readme-rewriter.md) | README with badges, hero, structured sections |
| [linter-setup](.claude/agents/repo-overhaul/linter-setup.md) | Biome / ESLint+Prettier / Ruff / rustfmt+clippy / golangci-lint |
| [pre-commit-setup](.claude/agents/repo-overhaul/pre-commit-setup.md) | husky + lint-staged OR pre-commit framework |
| [changelog-bootstrapper](.claude/agents/repo-overhaul/changelog-bootstrapper.md) | Release Please (single-pkg) or Changesets (monorepo) |
| [badge-applier](.claude/agents/repo-overhaul/badge-applier.md) | Standard badge row |

## Customization

Defaults live in [`SPEC.md §2`](.claude/agents/repo-overhaul/SPEC.md) — license,
default branch, CoC text, security disclosure preference, linter decision
tree, dependency-bot choice, CI structure, release flow, pre-commit policy,
README structure. To change a default, edit the SPEC and the relevant agent
prompt; everything downstream picks it up.

## Out of scope

Some checklist items require GitHub UI access and cannot be automated from
code. The orchestrator prints these as a punch-list at the end of every run:

- Enabling Dependabot security alerts (Settings → Security)
- Branch-protection rules
- Repository secrets (`NPM_TOKEN`, `CODECOV_TOKEN`, etc.)
- Enabling GitHub Discussions
- Filling `CODEOWNERS` with real team handles
- GitHub Pages / external docs hosting

## Safety

Four-layer defence-in-depth keeps sensitive paths (`.trash/`, `.env*`,
`report_*.xlsx`, IDE caches) out of any agent's reach — see
[`SPEC.md §5`](.claude/agents/repo-overhaul/SPEC.md). Layers: `.gitignore`,
Claude `permissions.deny`, a `PreToolUse` hook
(`.claude/hooks/protect-trash.cjs`) that pattern-matches dynamic tool calls,
and `pwd`-checks in the install scripts.

## Contributing

The SPEC is the source of truth. Any change to defaults — what license to
prefer, what linter to pick, how the CI matrix is shaped — should be made by
editing [`SPEC.md`](.claude/agents/repo-overhaul/SPEC.md) first, then
propagating to the relevant sub-agent prompts. New sub-agents follow the
pattern documented in
[`.claude/agents/repo-overhaul/README.md`](.claude/agents/repo-overhaul/README.md).

## License

MIT — see [LICENSE](LICENSE).
