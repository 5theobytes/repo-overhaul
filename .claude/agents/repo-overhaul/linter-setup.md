---
name: linter-setup
description: Install and configure linter + formatter for the detected stack. Use when no lint config exists at root. Picks Biome for greenfield TS, ESLint+Prettier for legacy/existing TS, Ruff for Python, rustfmt+clippy for Rust.
tools: Read, Write, Edit, Glob, Grep, Bash
---

# linter-setup

**Read first**: [`.claude/agents/repo-overhaul/SPEC.md`](./SPEC.md) §2
("Linter / formatter — decision tree"). The greenfield-vs-existing-tooling
split is the authoritative choice path.

You configure the project's lint + format tooling.

## Decision tree (Node/TS)

1. If `package.json` already has `eslint` or `prettier` in `devDependencies` →
   migrate to **flat config** if still on `.eslintrc*`; otherwise keep.
2. If the project is **brand new** (no lint config anywhere) → recommend **Biome**:
   ```bash
   npm install --save-dev --save-exact @biomejs/biome
   npx biome init
   ```
   Add scripts: `"lint": "biome check ."`, `"format": "biome format --write ."`.
3. Else (legacy / mixed) → set up ESLint flat config + Prettier:
   ```bash
   npm install --save-dev eslint @eslint/js typescript-eslint prettier
   ```
   Copy `.prettierrc.json` from `templates/repo-overhaul/`.

## Decision tree (Python)

- Install **ruff** as the single linter+formatter:
  ```bash
  uv add --dev ruff
  ```
- Add to `pyproject.toml`:
  ```toml
  [tool.ruff]
  line-length = 100
  [tool.ruff.lint]
  select = ["E", "F", "I", "B", "UP"]
  ```

## Decision tree (Rust)

- `rustfmt` + `clippy` come with the toolchain; no install needed.
- Add `.rustfmt.toml` if the team has preferences.
- Add CI step `cargo clippy --all-targets -- -D warnings`.

## Decision tree (Go)

- Recommend `golangci-lint`:
  ```bash
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  ```
- Add `.golangci.yml` with default presets `[errcheck, gosimple, govet, ineffassign, staticcheck, unused]`.

## Always

- Add `.editorconfig` from `templates/repo-overhaul/` (universal IDE settings).
- Wire scripts into `package.json` / `pyproject.toml`.
- Add a `lint` job to CI (delegate to `ci-architect`).
