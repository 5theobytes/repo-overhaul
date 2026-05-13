# Contributing to {{PROJECT_NAME}}

Thanks for your interest! This guide walks through the workflow we expect for
issues, pull requests, and local development.

## Code of Conduct

This project follows the [Contributor Covenant](./CODE_OF_CONDUCT.md). By
participating you agree to uphold it.

## Reporting bugs

1. Search [open issues]({{ISSUES_URL}}) first.
2. If none match, [open a new issue]({{NEW_ISSUE_URL}}) using the **Bug report**
   template. Include reproduction steps, expected vs actual behavior, and
   environment info.

## Suggesting features

Open an issue with the **Feature request** template. Explain the use case,
not just the implementation idea.

## Development setup

```bash
git clone {{REPO_URL}}
cd {{REPO_NAME}}
{{INSTALL_CMD}}
{{TEST_CMD}}
```

## Pull-request workflow

1. **Branch off `main`**: `git checkout -b feat/short-description`.
2. **Make focused commits**. Use [Conventional Commits](https://www.conventionalcommits.org/)
   when possible (`feat:`, `fix:`, `docs:`, `chore:`, …).
3. **Add tests** that fail before your change and pass after.
4. **Run the full check locally**:
   ```bash
   {{LINT_CMD}}
   {{TEST_CMD}}
   {{BUILD_CMD}}
   ```
5. **Open a PR** against `main`. Fill out the template — explain *what* and
   *why*, link the related issue (`Fixes #123`).
6. **Address review comments** by pushing additional commits (we squash on
   merge).

## Style

- Stick to the project's lint/format configuration; CI will block PRs that
  don't pass `{{LINT_CMD}}`.
- Prefer small, reviewable PRs (~< 400 lines diff) over megapatches.
- Don't include unrelated reformat-only changes in feature PRs.

## Releasing

Maintainers cut releases via `{{RELEASE_FLOW}}`. Contributors don't need to
bump versions in PRs.

## Questions?

Open a [Discussion]({{DISCUSSIONS_URL}}) or ping the maintainers in the
relevant issue.
