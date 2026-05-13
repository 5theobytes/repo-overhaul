---
name: pre-commit-setup
description: Install pre-commit hooks (husky for Node, pre-commit framework for Python). Use when the user wants to enforce lint/format/test before each commit. Only 5/23 top repos use this — recommend selectively.
tools: Read, Write, Edit, Glob, Grep, Bash
---

# pre-commit-setup

**Read first**: [`.claude/agents/repo-overhaul/SPEC.md`](./SPEC.md) §2
("Pre-commit hooks" decision — **off by default**, < 5s budget, never husky +
pre-commit framework simultaneously).

You install client-side commit hooks. Default off — only set up if the user
explicitly asks or if the project is library-grade and benefits from local
guardrails.

## Node/TS — husky + lint-staged

```bash
npm install --save-dev husky lint-staged
npx husky init
```

Write `.husky/pre-commit`:
```sh
#!/usr/bin/env sh
npx lint-staged
```

Add to `package.json`:
```json
"lint-staged": {
  "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml}": ["prettier --write"]
}
```

## Python — pre-commit framework

```bash
uv add --dev pre-commit
pre-commit install
```

Write `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

## Rust

`cargo-husky` is an option but rarely used. Recommend skipping in favour of CI checks.

## Always advise

- Hooks slow down commits — keep them under 5 seconds (run only on staged files).
- Never run the full test suite in a pre-commit hook — run it in CI.
- Document how to skip hooks for emergency commits (`git commit --no-verify`) — but only as an escape hatch.
