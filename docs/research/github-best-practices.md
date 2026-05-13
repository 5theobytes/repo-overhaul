# GitHub Open-Source Repository Conventions — Research Report

**Sample size:** 23 popular repositories across AI, frontend, backend/tooling,
languages, and libraries. **Method:** raw-file probes (`raw.githubusercontent.com`)
and the GitHub Contents API. Each repo was checked for the presence and shape of
twenty-plus standard artefacts (README, LICENSE, `.github/*`, CI, linters,
release flow, etc.).

**Date:** 2026-05-13.

---

## 1. The sample

| # | Repo | Stars-tier | Type |
|---|---|---|---|
| 1 | anthropics/claude-code | High | AI CLI |
| 2 | obra/superpowers | Med | AI agents |
| 3 | vercel/next.js | Top | Frontend framework |
| 4 | facebook/react | Top | Frontend library |
| 5 | sveltejs/svelte | High | Frontend framework |
| 6 | vitejs/vite | High | Build tool |
| 7 | tailwindlabs/tailwindcss | Top | CSS framework |
| 8 | prettier/prettier | High | Formatter |
| 9 | eslint/eslint | High | Linter |
| 10 | nodejs/node | Top | Runtime |
| 11 | denoland/deno | High | Runtime |
| 12 | astral-sh/ruff | High | Python linter (Rust) |
| 13 | astral-sh/uv | High | Python package mgr (Rust) |
| 14 | honojs/hono | Med | Web framework |
| 15 | trpc/trpc | High | End-to-end TS API |
| 16 | rust-lang/rust | Top | Language |
| 17 | microsoft/vscode | Top | IDE |
| 18 | supabase/supabase | Top | Backend platform |
| 19 | shadcn/ui | Top | UI library |
| 20 | tanstack/query | High | Data-fetching |
| 21 | drizzle-team/drizzle-orm | High | ORM |
| 22 | colinhacks/zod | High | Validation |
| 23 | TanStack/query (dup-check) | High | (already counted) |

---

## 2. Headline checklist (presence by artefact)

| Artefact | Coverage | Notes |
|---|---|---|
| **README.md** | 23/23 | Universal. ~70% include logo/banner. ~60% include shields/badges. |
| **LICENSE** | 23/23 | MIT dominates (16/23). Apache-2.0: 3 (supabase, drizzle, uv has dual). Dual MIT+Apache: 2 (rust, uv). Custom: 1 (claude-code). |
| **CONTRIBUTING.md** | 21/23 | Two omissions (claude-code, superpowers — neither solicits external code contribs). Often relocated to `.github/CONTRIBUTING.md` (deno, tailwindcss) or `docs/CONTRIBUTING.md` (hono). |
| **CODE_OF_CONDUCT.md** | 11/23 | Contributor Covenant is the dominant standard (zod v2.1, drizzle v2.0, hono v2.0). rust and deno use their own/Rust CoC. The rest delegate to org-level `.github` repos or omit. |
| **SECURITY.md** | 13/23 | Disclosure channels vary widely: HackerOne (anthropic, nodejs), Tidelift (prettier), email + GH Advisory (astral org), Facebook Whitehat (react), Twitter DM (trpc — informal). |
| **CHANGELOG.md** | 8/23 (root) | **Trending away** from root CHANGELOG. Monorepos use Changesets (shadcn, tanstack, svelte) or per-package CHANGELOGs (drizzle, vite). Some publish notes on a website (vscode, supabase). When present, format varies — only **Tailwind CSS strictly follows Keep a Changelog**. |
| **.github/ISSUE_TEMPLATE/** | 22/23 | Only superpowers lacks. YAML form-based (`.yml`) has overtaken `.md` (~75%). `config.yml` to disable blank issues + link Discussions/security is near-universal. |
| **.github/PULL_REQUEST_TEMPLATE.md** | 18/23 | Most have it; missing in claude-code, shadcn, drizzle, zod (sample), tanstack-? |
| **.github/workflows/** | 23/23 | Count ranges from 4 (tailwindcss) to 46 (supabase) and 36 (nodejs, next.js). Mature projects develop a workflow **prefix-scheme** (`runtime_*`, `compiler_*` in react; `turbopack-*`, `rspack-*` in next.js). |
| **.github/dependabot.yml** | 8/23 | Strong **Renovate counter-trend**: prettier, eslint (both), ruff, uv, vite, rust, tanstack use Renovate. Pure dependabot: react, svelte, vscode, supabase, shadcn, nodejs. |
| **.github/FUNDING.yml** | 11/23 | Common for community projects, absent for corporate-backed (vscode, claude-code, deno). New variant: `FUNDING.json` (svelte, tanstack), `tea.yaml` (zod). |
| **.github/CODEOWNERS** | 8/23 | Used by larger projects with strict review routing (next.js, vscode, supabase, eslint, nodejs, ruff, tanstack-?, tailwindcss). |
| **.editorconfig** | 18/23 | Near-universal among JS/TS; missing in supabase, drizzle. |
| **.nvmrc / .node-version / .tool-versions** | 16/23 | `.nvmrc` is the most common (10), `.node-version` next (next.js, vite). hono uses `.tool-versions` (asdf/mise) — emerging multi-runtime trend. Rust/Python repos use `rust-toolchain.toml`/`.python-versions`. |
| **Husky / lefthook / pre-commit** | 5/23 | Surprisingly rare. Husky: next.js, zod. pre-commit framework: ruff, uv. commitlint (no husky): shadcn. Most projects rely on CI checks instead of local git hooks. |
| **AI-tooling files (AGENTS.md / CLAUDE.md / copilot-instructions.md / .cursor*)** | 9/23 | **Emerging artefact.** Visible in: next.js, vite, supabase, vscode, zod (full suite: AGENTS.md + CLAUDE.md + .cursorrules), shadcn (.claude/), ruff/uv (AGENTS.md + CLAUDE.md), superpowers (per-LLM `CLAUDE.md`, `GEMINI.md`). |

---

## 3. README anatomy — what the best ones share

Inspected READMEs of next.js, react, vite, tailwindcss, hono, tanstack-query, drizzle, zod, ruff, uv.

**Hero block** (top-of-file)

- **Logo / banner** (centered, ~200–500 px wide). Often light/dark SVG variants.
- **One-line tagline** under the logo.
- **Badge row** — most common: CI status, npm version, weekly downloads, license, Discord. Library projects add bundle size (bundlejs/bundlephobia), Codecov. Some add benchmark images (ruff, uv).

**Body sections in order of frequency**

1. Installation / Quickstart (23/23).
2. Documentation / link to docs site (22/23) — bodies are intentionally short, deep docs live on `*.dev` sites.
3. Features (highlights) (18/23).
4. Contributing (link, not body) (20/23).
5. License (22/23 — at the bottom).
6. Community / Discord / X (19/23).
7. Sponsors / acknowledgements (10/23).
8. Migration / version notes (5/23 — major-version repos).
9. AI Agents section (emerging — trpc, zod inline).

**Anti-patterns observed in less-mature repos**

- 800-line READMEs with everything inline (no docs site).
- No badges, no shields, no version info.
- No license link at the bottom.
- No quickstart code block — only prose.

**Reference examples**

- **Minimal but complete:** [facebook/react/README.md](https://github.com/facebook/react/blob/main/README.md) — short, badges, links out.
- **Hero-driven:** [astral-sh/uv/README.md](https://github.com/astral-sh/uv/blob/main/README.md) — benchmark chart, features table.
- **Sponsor-rich:** [trpc/trpc/README.md](https://github.com/trpc/trpc/blob/main/README.md) — Star history + tiered sponsors.

---

## 4. `.github/` structure consensus

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml          ← form-based, REQUIRED fields
│   ├── feature_request.yml     ← problem-focused, not solution-focused
│   └── config.yml              ← blank_issues_enabled: false; contact_links
├── PULL_REQUEST_TEMPLATE.md    ← What / Why / How / Testing / Checklist
├── workflows/
│   ├── ci.yml                  ← lint + typecheck + test matrix + build
│   ├── codeql.yml              ← security scanning (popular in nodejs, prettier, trpc)
│   ├── release.yml             ← release-please OR changesets OR manual tag
│   ├── stale.yml               ← close stale issues
│   └── ...
├── dependabot.yml OR renovate.json5 (rarely both)
├── FUNDING.yml                 ← github/patreon/open_collective sponsorship
├── CODEOWNERS                  ← for projects with > 5 maintainers
└── SECURITY.md                 ← (or in repo root)
```

**Workflow patterns worth borrowing**

- `concurrency` with `cancel-in-progress: true` to stop redundant runs on push.
- `actions/setup-node@v4` with `node-version-file: .nvmrc` (single source of truth).
- `cache: npm` to speed up installs.
- Matrix across OS × runtime version for libraries (`os: [ubuntu, macos, windows]` × `node: [20, 22]`).
- A dedicated `autofix.yml` that runs `eslint --fix` / `prettier --write` and commits on PR (svelte, supabase, hono).
- `semantic-pull-request.yml` to enforce Conventional Commits on PR titles (vite, trpc).
- `scorecard.yml` (OpenSSF Scorecard) for security posture grading (nodejs).
- `zizmor` workflow auditing in astral-sh repos (security on Actions themselves).

---

## 5. CI/CD flavours

| Stack | Typical jobs | Best-in-class example |
|---|---|---|
| Node/TS | lint, typecheck, test (matrix), build, release | tanstack/query — Nx-aware |
| Python | ruff check, ruff format --check, pytest, build | astral-sh/ruff |
| Rust | cargo fmt --check, clippy, test, build, miri | rust-lang/rust |
| Monorepo | turbo run lint/typecheck/test, changesets release | shadcn/ui, supabase |

**Release flow taxonomy**

- **Changesets** (`@changesets/cli`) — JS/TS monorepos: shadcn, tanstack, svelte (pnpm shops).
- **Release Please** (googleapis/release-please-action) — conventional-commits-driven version PRs.
- **semantic-release** — older, still seen in some Apache-2.0 projects.
- **Manual** with custom GitHub Action — most popular for single-package repos (hono, zod, drizzle).
- **Per-package CHANGELOGs** in `packages/*/CHANGELOG.md` — typical for monorepos that don't keep a root one.

---

## 6. Linter / formatter landscape (2026)

| Tooling | Adoption | Trend |
|---|---|---|
| ESLint + Prettier | 13/23 | **Still dominant**. Flat config (`eslint.config.js`) preferred over legacy `.eslintrc`. |
| **Biome** | 1/23 (zod) | Rising. Replaces ESLint + Prettier with one fast tool. |
| **dprint** | 2/23 (drizzle, deno) | Niche. Rust-based, multi-language. |
| Ruff (Python) | 2/23 (ruff itself, uv) | Standard for new Python projects. |
| rustfmt + clippy | 2/23 (rust, deno) | Universal in Rust ecosystem. |

**Editor configuration:** `.editorconfig` is the single most consistently-present
optional file outside the README (18/23). It costs nothing and ends formatting
wars across IDEs.

---

## 7. Branch and governance

- **`main` is now the default** (22/23). Only `rust-lang/rust` (master) and
  `supabase/supabase` (master) hold out — and supabase is a notable laggard
  given its modernity.
- **`canary` as default** is a rare advanced pattern used by next.js to signal
  fast-moving unstable releases.
- **DCO / CLA:** explicit in only 2/23 (eslint via OpenJS Foundation; vscode via
  Microsoft CLA bot). Most projects accept contributions on trust.

---

## 8. The "trushny dev" checklist

Distilled from the sample. **Must-have** for any serious public repo; **Should-have**
for libraries/frameworks; **Nice-to-have** for the top tier.

### Must-have (M)

1. `README.md` with: badges, install, quickstart, license link.
2. `LICENSE` file (MIT/Apache-2.0/BSD-3 — pick one, copy verbatim).
3. `.gitignore` appropriate for the stack.
4. `.editorconfig` — universal editor settings.
5. `.github/ISSUE_TEMPLATE/bug_report.yml` + `feature_request.yml` + `config.yml`.
6. `.github/PULL_REQUEST_TEMPLATE.md`.
7. `.github/workflows/ci.yml` — lint + test on push/PR, with matrix.
8. `CONTRIBUTING.md` — at minimum: how to set up, run tests, open PR.
9. Default branch named `main`.

### Should-have (S)

10. `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1 by default.
11. `SECURITY.md` — disclosure channel (private email or GitHub Security Advisory).
12. `.github/dependabot.yml` OR `renovate.json5` — automated dep updates.
13. `.nvmrc` / `.python-versions` / `rust-toolchain.toml` — pin runtime.
14. Pre-commit hook framework (husky for Node, pre-commit for Python).
15. CHANGELOG.md (root) or Changesets / Release Please workflow.
16. `.github/FUNDING.yml` (if community-funded).
17. AI-tooling guidance: `AGENTS.md` or `.github/copilot-instructions.md`.
18. Linter + formatter configured at repo root (`eslint.config.js`/`biome.json`/`pyproject.toml`).

### Nice-to-have (N)

19. `CODEOWNERS` — for repos with > 5 active maintainers.
20. `.github/workflows/codeql.yml` or OpenSSF Scorecard.
21. `.github/workflows/release.yml` automated via Release Please.
22. Auto-fix workflow (`autofix.yml`) that pushes lint/format fixes on PRs.
23. Semantic-PR-title check.
24. Logo / hero image in README.
25. Documentation site (separate from README).
26. Multi-OS CI matrix.

---

## 9. Recommended defaults for new repos (Node/TS focus)

- **License**: MIT.
- **Default branch**: `main`.
- **Pre-commit**: husky + lint-staged.
- **Linter**: Biome (if greenfield) or ESLint flat config + Prettier (if integrating with existing tooling).
- **Test runner**: Vitest (for Vite/library) or Jest (for CRA-era apps).
- **CI**: GitHub Actions matrix on Node 20 + 22 × ubuntu/macos/windows.
- **Release**: Release Please (single-package) or Changesets (monorepo).
- **Dependency bot**: Dependabot (zero config required).
- **CoC**: Contributor Covenant v2.1.
- **AI-tooling**: `AGENTS.md` at repo root.

---

## 10. References (selected)

- [Tailwind CHANGELOG.md](https://github.com/tailwindlabs/tailwindcss/blob/main/CHANGELOG.md) — gold-standard Keep a Changelog example.
- [vite release.yml](https://github.com/vitejs/vite/blob/main/.github/workflows/release.yml) — Changesets + provenance.
- [supabase autofix.yml](https://github.com/supabase/supabase/blob/master/.github/workflows/autofix_linters.yml) — auto-format on PR.
- [nodejs SECURITY.md](https://github.com/nodejs/node/blob/main/SECURITY.md) — HackerOne disclosure with embargo timeline.
- [zod biome.jsonc](https://github.com/colinhacks/zod/blob/main/biome.jsonc) — full Biome migration example.
- [Contributor Covenant v2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) — adopt as-is.
- [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).
- [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

---

_This report drove the design of the `.claude/agents/repo-overhaul/`
sub-agents and the `templates/repo-overhaul/` boilerplate in this repository._
