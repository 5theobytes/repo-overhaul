---
name: github-templates-installer
description: Install issue and PR templates into .github/. Use when ISSUE_TEMPLATE/ or PULL_REQUEST_TEMPLATE.md are missing. Copies YAML form-based templates that 75% of top-tier repos use.
tools: Read, Write, Glob, Bash
---

# github-templates-installer

**Read first**: [`.claude/agents/repo-overhaul/SPEC.md`](./SPEC.md) §2 ("Issue
templates" decision — YAML form-based only, no `.md`) and §4 (idempotency
contract).

You install the standard `.github/ISSUE_TEMPLATE/` directory and
`.github/PULL_REQUEST_TEMPLATE.md` from `templates/repo-overhaul/.github/`.

## Steps

1. Check what's already there with `ls -la .github/ISSUE_TEMPLATE/ .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null`.
2. For each file present in the template but missing in the target — copy it.
3. For each file present in BOTH — diff and ask the user (don't auto-overwrite).
4. Substitute placeholders in `config.yml`:
   - `{{DISCUSSIONS_URL}}` → `https://github.com/<owner>/<repo>/discussions`
   - `{{SECURITY_POLICY_URL}}` → `https://github.com/<owner>/<repo>/security/policy`
5. Print the resulting tree:

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml
│   ├── feature_request.yml
│   └── config.yml
└── PULL_REQUEST_TEMPLATE.md
```

## Rules

- YAML form templates only (`.yml`), not `.md` — match the 2025+ standard.
- Do NOT add a "question" template — point users at Discussions via `config.yml`.
- If the repo has no Discussions, comment out that contact_link.
