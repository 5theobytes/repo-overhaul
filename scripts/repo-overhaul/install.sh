#!/usr/bin/env bash
# install.sh — Orchestrator for the repo-overhaul toolkit (macOS / Linux / WSL).
#
# Detects the project stack, prompts for metadata, copies templates with
# placeholder substitution, and prints a punch-list of follow-ups.
#
# Usage:
#   bash scripts/repo-overhaul/install.sh
#
# Run from the *target* repo's root, OR pass --target /path/to/repo.

set -euo pipefail

# Resolve directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$TOOLKIT_ROOT/templates/repo-overhaul"
TARGET_DIR="${1:-$(pwd)}"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "❌ Templates directory not found: $TEMPLATES_DIR" >&2
  exit 1
fi
cd "$TARGET_DIR"

# Refuse to run if the user accidentally targets the quarantine directory.
# Excluded paths come from SPEC §5.
case "$(pwd)" in
  */.trash|*/.trash/*)
    echo "❌ Refusing to scaffold inside .trash/ (SPEC §5 excluded path)." >&2
    exit 1 ;;
esac

# Detect stack
detect_stack() {
  if [[ -f package.json ]]; then echo "node"
  elif [[ -f pyproject.toml ]] || [[ -f requirements.txt ]] || [[ -f setup.py ]]; then echo "python"
  elif [[ -f Cargo.toml ]]; then echo "rust"
  elif [[ -f go.mod ]]; then echo "go"
  else echo "unknown"
  fi
}

STACK=$(detect_stack)
echo "📦 Detected stack: $STACK"

# Gather metadata
read -r -p "Project name [$(basename "$TARGET_DIR")]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$(basename "$TARGET_DIR")}

read -r -p "Author / org name [$(git config user.name 2>/dev/null || echo 'unknown')]: " AUTHOR
AUTHOR=${AUTHOR:-$(git config user.name 2>/dev/null || echo 'unknown')}

read -r -p "License [MIT]: " LICENSE
LICENSE=${LICENSE:-MIT}

YEAR=$(date -u +%Y)
DATE=$(date -u +%Y-%m-%d)

# Helper: copy template with placeholder substitution
substitute() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    echo "  ⚠ skip (exists): $dst"
    return
  fi
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{AUTHOR}}|$AUTHOR|g" \
    -e "s|{{LICENSE}}|$LICENSE|g" \
    -e "s|{{YEAR}}|$YEAR|g" \
    -e "s|{{DATE}}|$DATE|g" \
    "$src" > "$dst"
  echo "  ✓ created: $dst"
}

echo
echo "📂 Copying templates..."

# LICENSE
case "$LICENSE" in
  MIT)        substitute "$TEMPLATES_DIR/LICENSE-mit.txt"        LICENSE ;;
  Apache-2.0) substitute "$TEMPLATES_DIR/LICENSE-apache-2.0.txt" LICENSE ;;
  *)          echo "  ⚠ unknown license $LICENSE — skipping LICENSE file" ;;
esac

# Community files
substitute "$TEMPLATES_DIR/CONTRIBUTING.md"     CONTRIBUTING.md
substitute "$TEMPLATES_DIR/CODE_OF_CONDUCT.md"  CODE_OF_CONDUCT.md
substitute "$TEMPLATES_DIR/SECURITY.md"         SECURITY.md
substitute "$TEMPLATES_DIR/CHANGELOG.md"        CHANGELOG.md

# Editor / tooling
substitute "$TEMPLATES_DIR/.editorconfig"   .editorconfig
substitute "$TEMPLATES_DIR/.gitattributes"  .gitattributes
[[ "$STACK" == "node" ]] && substitute "$TEMPLATES_DIR/.nvmrc"         .nvmrc
[[ "$STACK" == "node" ]] && substitute "$TEMPLATES_DIR/.prettierrc.json" .prettierrc.json

# .github/
substitute "$TEMPLATES_DIR/.github/ISSUE_TEMPLATE/bug_report.yml"      .github/ISSUE_TEMPLATE/bug_report.yml
substitute "$TEMPLATES_DIR/.github/ISSUE_TEMPLATE/feature_request.yml" .github/ISSUE_TEMPLATE/feature_request.yml
substitute "$TEMPLATES_DIR/.github/ISSUE_TEMPLATE/config.yml"          .github/ISSUE_TEMPLATE/config.yml
substitute "$TEMPLATES_DIR/.github/PULL_REQUEST_TEMPLATE.md"           .github/PULL_REQUEST_TEMPLATE.md
substitute "$TEMPLATES_DIR/.github/dependabot.yml"                     .github/dependabot.yml
substitute "$TEMPLATES_DIR/.github/FUNDING.yml"                        .github/FUNDING.yml
substitute "$TEMPLATES_DIR/.github/CODEOWNERS"                         .github/CODEOWNERS

# CI workflow by stack
case "$STACK" in
  node)   substitute "$TEMPLATES_DIR/.github/workflows/ci-node.yml"   .github/workflows/ci.yml ;;
  python) substitute "$TEMPLATES_DIR/.github/workflows/ci-python.yml" .github/workflows/ci.yml ;;
  *)      echo "  ⚠ no CI workflow template for stack: $STACK" ;;
esac
substitute "$TEMPLATES_DIR/.github/workflows/release-please.yml" .github/workflows/release-please.yml

# README — only if missing
if [[ ! -e README.md ]]; then
  substitute "$TEMPLATES_DIR/README.template.md" README.md
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Repo overhaul scaffolding complete."
echo
echo "📋 Manual follow-ups:"
echo "  1. Fill placeholders ({{...}}) in the generated files — grep for '{{'."
echo "  2. Replace .github/CODEOWNERS with your team / users."
echo "  3. Configure repository secrets in GitHub Settings → Actions:"
echo "     • NPM_TOKEN (if publishing to npm)"
echo "     • CODECOV_TOKEN (if using Codecov)"
echo "  4. Enable Dependabot security alerts in Settings → Security."
echo "  5. Adopt Conventional Commits in CONTRIBUTING.md."
echo "  6. Run the per-feature sub-agents from .claude/agents/repo-overhaul/"
echo "     for deeper README rewrites, linter setup, etc."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
