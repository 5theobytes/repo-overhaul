# Repo Overhaul — Specification

**This is the source of truth every sub-agent in `.claude/agents/repo-overhaul/`
MUST read before acting.** Keep it short (< 400 lines). Decisions live here;
the *evidence* behind those decisions lives in
[`docs/research/github-best-practices.md`](../../../docs/research/github-best-practices.md).

If a decision in this SPEC contradicts the research doc, **this SPEC wins** —
it's the curated outcome of the research, not the raw data.

---

## 1. The 24-point checklist

A repo is "trushny" when it satisfies these items. Each sub-agent owns a slice.

### Must-have (M, 9 items) — block PR-readiness without these

| # | Item | Owner agent |
|---|---|---|
| M1 | `README.md` with badges, install, quickstart, license link | `readme-rewriter` |
| M2 | `LICENSE` at root (MIT default) | `license-applier` |
| M3 | `.gitignore` matching the stack | _(scaffolded by stack tooling)_ |
| M4 | `.editorconfig` | `github-templates-installer` (bundled) |
| M5 | `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}.yml` | `github-templates-installer` |
| M6 | `.github/PULL_REQUEST_TEMPLATE.md` | `github-templates-installer` |
| M7 | `.github/workflows/ci.yml` — lint + test on push/PR | `ci-architect` |
| M8 | `CONTRIBUTING.md` | `contributing-writer` |
| M9 | Default branch = `main` | _(manual; ci-architect flags if wrong)_ |

### Should-have (S, 9 items)

| # | Item | Owner agent |
|---|---|---|
| S10 | `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1) | `contributing-writer` |
| S11 | `SECURITY.md` with private disclosure | `security-policy-writer` |
| S12 | `.github/dependabot.yml` OR `renovate.json*` | `ci-architect` (bundled with workflows) |
| S13 | Runtime pin (`.nvmrc` / `.python-versions` / `rust-toolchain.toml`) | `ci-architect` |
| S14 | Pre-commit hooks (husky / pre-commit framework) | `pre-commit-setup` |
| S15 | `CHANGELOG.md` OR `.changeset/` directory | `changelog-bootstrapper` |
| S16 | `.github/FUNDING.yml` | `github-templates-installer` |
| S17 | AI-tooling files (`AGENTS.md` / `.github/copilot-instructions.md`) | `readme-rewriter` (mention only) |
| S18 | Linter + formatter at root | `linter-setup` |

### Nice-to-have (N, 6 items)

| # | Item | Owner agent |
|---|---|---|
| N19 | `.github/CODEOWNERS` | `github-templates-installer` (skeleton) |
| N20 | CodeQL or OpenSSF Scorecard workflow | `ci-architect` (offer to add) |
| N21 | Release automation (Release Please / Changesets) | `changelog-bootstrapper` |
| N22 | Auto-fix workflow (`autofix.yml`) | `ci-architect` (offer to add) |
| N23 | Semantic PR title check | `ci-architect` (offer to add) |
| N24 | Logo / hero image in README | `readme-rewriter` (ask user) |

**Score formula:** `score = sum(M present) + sum(S present) + sum(N present)` out
of 24. Report as `Score: N/24 (M: x/9, S: y/9, N: z/6)`.

---

## 2. Decisions (curated defaults)

### License

- **Default**: MIT. Used in 16/23 surveyed repos. Liberal, GH-recognisable.
- **Apache-2.0** if the project includes patent claims or follows Rust convention.
- **Dual MIT + Apache-2.0** only for Rust libraries (matches ecosystem norm).
- Never invent a custom license.

### Default branch

- **`main`** always. If repo is on `master`, flag it; don't auto-rename.

### Code of Conduct

- **Contributor Covenant v2.1** — copy verbatim from `templates/repo-overhaul/CODE_OF_CONDUCT.md`.
- Do not invent enforcement mechanisms. The text already says "community leaders" — leave it generic.
- Replace ONLY `{{CONTACT_EMAIL}}`.

### Security disclosure channel — preference order

1. **GitHub Security Advisory** (`/security/advisories/new`) — preferred. Coordinated, signed, CVE-ready.
2. **Private email** to a list address (not a personal mailbox).
3. **HackerOne** — only if project is already enrolled.

Never: public issues, Discord, public Slack, Twitter DMs.

### Linter / formatter — decision tree

| Stack | Greenfield | Existing tooling |
|---|---|---|
| TS/JS | **Biome** (single tool, fast, replaces ESLint+Prettier) | Keep ESLint+Prettier; migrate to **flat config** if on legacy `.eslintrc*` |
| Python | **Ruff** (linter + formatter in one) | Ruff regardless — it's universally adopted |
| Rust | `rustfmt` + `clippy` | Same |
| Go | `gofmt` + **golangci-lint** | Same |

### Dependency-update bot

- **Default**: Dependabot (zero config, GitHub-native).
- **Renovate** if the project needs grouped updates, custom schedules, or non-npm
  ecosystems. Configured via `renovate.json5` in `.github/`.
- Never enable both simultaneously.

### CI structure (minimum)

Every `ci.yml` must have:

1. `concurrency` with `cancel-in-progress: true`.
2. Jobs: `lint`, `typecheck` (typed langs only), `test` (matrix), `build`.
3. Matrix: OS × runtime version for libraries; single OS for apps.
4. Caching: `cache: npm` / `cache: pip`.
5. Runtime pin via `node-version-file: .nvmrc` (single source of truth).

### Release flow

| Repo shape | Tool |
|---|---|
| Single package | **Release Please** |
| Monorepo (pnpm/turbo/nx) | **Changesets** |
| Has manual CHANGELOG already | Keep it; enforce Keep a Changelog format |

### Pre-commit hooks

- **Off by default.** Only 5/23 surveyed repos use them.
- Add only if the user asks OR the project is library-grade with strict style.
- Node: `husky` + `lint-staged`. Python: `pre-commit` framework. Never both.
- Hooks must run < 5 seconds on a typical commit (lint staged files only — never the full test suite).

### README structure

1. **Hero** — logo (optional), name, tagline, ≤ 6 badges (CI, version, downloads, license, bundle size, Discord).
2. Features (3-7 bullets).
3. Quickstart (code block).
4. Installation.
5. Usage (minimal example).
6. Testing.
7. Contributing → link.
8. Security → link.
9. License → link.

Hard limit: **200 lines**. Offload depth to `docs/` or external site.

### Issue templates

- **YAML form-based** (`.yml`), not `.md`. 75% of top-tier repos have migrated.
- Always include `config.yml` with `blank_issues_enabled: false` and contact links to Discussions + security policy.

---

## 3. Placeholders the substitutor knows

| Placeholder | Resolved from | Fallback |
|---|---|---|
| `{{PROJECT_NAME}}` | `package.json#name` / `pyproject.toml#project.name` / `Cargo.toml#package.name` / directory name | ask user |
| `{{AUTHOR}}` | `package.json#author` / git config user.name | ask user |
| `{{LICENSE}}` | `package.json#license` / SPDX in `pyproject.toml` | MIT |
| `{{YEAR}}` | current UTC year | — |
| `{{DATE}}` | current UTC `YYYY-MM-DD` | — |
| `{{OWNER}}/{{REPO}}` | `git remote get-url origin` parsed | ask user |
| `{{CONTACT_EMAIL}}` | maintainer email from package.json / git config | ask user |
| `{{SECURITY_EMAIL}}` | derived: `security@<domain>` from `{{CONTACT_EMAIL}}` | ask user |
| `{{DISCUSSIONS_URL}}` | `https://github.com/{{OWNER}}/{{REPO}}/discussions` | — |

---

## 4. Idempotency contract

Every writing sub-agent MUST:

1. Check whether the target file exists.
2. If absent → create it.
3. If present and trivially short (≤ 30 lines, looks like a stub) → diff and ask permission to overwrite.
4. If present with substantial content (> 30 lines) → NEVER overwrite; offer a `.proposed` sibling file or print the diff and ask the user to merge by hand.
5. Re-running the same agent twice in a row MUST result in zero changes on the second run.

---

## 5. Out of scope for these sub-agents

These belong to the user / GitHub UI / repo admin, not to any agent:

- Enabling Dependabot security alerts (Settings → Security).
- Creating branch-protection rules.
- Adding repository secrets (`NPM_TOKEN`, `CODECOV_TOKEN`).
- Enabling GitHub Discussions.
- Setting up GitHub Pages or external docs hosting.
- Filling `CODEOWNERS` with real team handles.
- Choosing release maintainers.

The orchestrator (`/overhaul-repo`) prints these as a punch-list at the end.

### Excluded paths (NEVER scan, audit, modify, copy, or generate inside)

The following paths are **invisible** to every sub-agent in this toolkit. Skip
them when listing files, computing checklist scores, generating READMEs,
copying templates, or running any other operation:

| Path | Reason |
|---|---|
| `.trash/` | Local quarantine for files the user moved out of the repo's public surface (client reports, IDE caches, leftover artefacts). |
| `node_modules/` | Dependency installs. |
| `build/`, `dist/`, `out/`, `target/` | Build outputs. |
| `coverage/`, `.nyc_output/` | Test coverage artefacts. |
| `.git/` | Git internals. |
| `.qoder/`, `.vscode/`, `.idea/`, `.cursor/` | IDE / external-tool caches. |
| `.env*` | Secrets (already in `.gitignore` for most projects). |
| `*.xlsx`, `*.csv`, `*.parquet` at the repo root (and `report_*` everywhere) | Likely contain client data; even if not, they aren't source. |

When the user adds something to `.trash/`, it stays there permanently — agents
must never propose to "clean up" or "restore" files from `.trash/`.

If a sub-agent needs to walk the file tree (e.g. `repo-auditor`, `readme-rewriter`
inspecting examples), it must build its file list with these exclusions applied,
e.g. `git ls-files` (already respects `.gitignore`) or
`find . -path ./.trash -prune -o -path ./node_modules -prune -o -print`.

### Defence in depth

Excluded paths are protected at **four layers** so that no single
misconfiguration leaks data into a Claude session:

| Layer | File | Purpose |
|---|---|---|
| 1. Git | `.gitignore` | `.trash/`, `report_*.xlsx`, `.qoder/`, `.env*`, `.vscode/`, `.idea/` never enter version control. |
| 2. Claude permissions | `.claude/settings.json` → `permissions.deny` | Static deny-list refuses tool calls to excluded paths before they reach the model. Shared across the team via the committed settings file. |
| 3. Claude hook | `.claude/hooks/protect-trash.cjs` | `PreToolUse` hook that pattern-matches `tool_input` (paths, globs, Bash commands, MultiEdit arrays) and exits with code 2 on any match. Catches dynamic / unanticipated tool calls the static deny-list might miss. |
| 4. Tool scripts | `install.sh`, `install.ps1`, `detect-stack.sh` | Refuse to run when `pwd` is inside `.trash/`. |

If you change the excluded-paths list above, update all four layers in lockstep
(the `.gitignore` block, `settings.json` deny entries, the `FORBIDDEN_PATTERNS`
array in the hook, and the path checks in the install scripts).

### Stronger options (out of scope for this toolkit, but worth knowing)

For data sensitive enough that even an unblocked tool call would be a problem:

- **OS-level deny ACL.** On Windows: `icacls .trash /deny "%USERNAME%:(R)"`.
  On macOS/Linux: `chmod -R 000 .trash/` (re-readable with `chmod -R u+rw`).
  Blocks reads at the kernel — defeats Bash, hooks, and any sandbox bypass.
- **Move out of repo entirely.** `.trash/` lives in the working directory, so it
  is still inside the sandbox root. To make Claude *unable to reach* the data,
  move it outside the project root (e.g. to `~/my-project-private/`).
- **Encryption at rest.** Age, `openssl enc`, or 7-Zip with a password. Data is
  unreadable even if a tool call succeeds.

---

## 6. Evidence base

For each decision above, the underlying data — frequencies, exemplar repos,
counter-examples — lives in:
- [`docs/research/github-best-practices.md`](../../../docs/research/github-best-practices.md) (full 23-repo survey).

When a sub-agent encounters an edge case not covered here, it may consult the
research doc, but should propose a SPEC update via a comment rather than acting
on raw research alone.
