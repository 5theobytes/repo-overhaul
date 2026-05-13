---
name: changelog-bootstrapper
description: Set up changelog automation. Use when CHANGELOG.md is missing and the project wants automated releases. Picks Release Please for single-package, Changesets for monorepos.
tools: Read, Write, Edit, Glob, Grep, Bash
---

# changelog-bootstrapper

**Read first**: [`.claude/agents/repo-overhaul/SPEC.md`](./SPEC.md) §2
("Release flow" — Release Please for single packages, Changesets for monorepos,
keep manual CHANGELOG if already established).

You bootstrap a release/changelog workflow.

## Decision

| Repo shape | Tool | Rationale |
|---|---|---|
| Single package | **Release Please** | Conventional commits → version-bump PR. Lowest setup cost. |
| Monorepo (pnpm/turborepo/nx) | **Changesets** | Per-package versioning; manual changeset opt-in per PR. |
| Already has manual CHANGELOG.md | **Keep manual** | Don't disturb existing flow; just enforce Keep a Changelog format. |

## Release Please setup

1. Copy `templates/repo-overhaul/.github/workflows/release-please.yml` to `.github/workflows/`.
2. Set `release-type` to match the stack (`node`, `python`, `rust`, `go`, etc.).
3. Add a starter `CHANGELOG.md` from `templates/repo-overhaul/CHANGELOG.md` with `{{DATE}}` replaced.

## Changesets setup

```bash
npm install --save-dev @changesets/cli
npx changeset init
```

This creates `.changeset/config.json`. Recommend defaults:
```json
{
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": []
}
```

Add `.github/workflows/changesets-release.yml`:
```yaml
name: Release
on: { push: { branches: [main] } }
permissions: { contents: write, pull-requests: write }
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version-file: .nvmrc, cache: npm }
      - run: npm ci
      - uses: changesets/action@v1
        with:
          publish: npm run release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Manual CHANGELOG (Keep a Changelog format)

Use `templates/repo-overhaul/CHANGELOG.md`. Document in CONTRIBUTING.md:

> When opening a PR with user-visible changes, add an entry under the
> `[Unreleased]` section in one of: Added / Changed / Fixed / Removed.
