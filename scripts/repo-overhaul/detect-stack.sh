#!/usr/bin/env bash
# detect-stack.sh — print the detected project stack name and exit.
#
# Outputs one of: node, python, rust, go, mixed, unknown.
# Used by other scripts; can also be called standalone:
#   bash scripts/repo-overhaul/detect-stack.sh

set -euo pipefail

cd "${1:-$(pwd)}"

# Refuse to run inside the quarantine (SPEC §5 excluded path).
case "$(pwd)" in
  */.trash|*/.trash/*)
    echo "unknown" ; exit 0 ;;
esac

declare -a stacks=()
[[ -f package.json     ]] && stacks+=("node")
[[ -f pyproject.toml   ]] && stacks+=("python")
[[ -f requirements.txt ]] && stacks+=("python")
[[ -f setup.py         ]] && stacks+=("python")
[[ -f Cargo.toml       ]] && stacks+=("rust")
[[ -f go.mod           ]] && stacks+=("go")
[[ -f Gemfile          ]] && stacks+=("ruby")

# Deduplicate
mapfile -t uniq < <(printf '%s\n' "${stacks[@]+"${stacks[@]}"}" | awk '!seen[$0]++')

case "${#uniq[@]}" in
  0) echo "unknown" ;;
  1) echo "${uniq[0]}" ;;
  *) echo "mixed:${uniq[*]}" ;;
esac
