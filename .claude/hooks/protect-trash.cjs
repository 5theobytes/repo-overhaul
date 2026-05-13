#!/usr/bin/env node
// PreToolUse hook that blocks every tool call touching .trash/ or other
// excluded paths from SPEC §5. Cross-platform: needs only Node, no jq.
//
// Wired in .claude/settings.json under hooks.PreToolUse.
//
// Exit codes:
//   0 → allow
//   2 → block (Claude Code converts this into a tool-use error visible to me)

const fs = require('fs');

// Excluded paths — keep in sync with SPEC §5 and .gitignore.
// The "boundary" character class `[^a-zA-Z0-9_.-]` matches anywhere a path
// would naturally start in a Bash command (spaces, quotes, redirects, pipes)
// or a path string (slashes). This catches both:
//   - paths:   "src/.trash/foo"
//   - bash:    "cat .trash/secret"  |  "ls   .trash"  |  "rm '.trash/x'"
const BOUNDARY = '(?:^|[^a-zA-Z0-9_.\\-])';
const END = '(?:[\\\\/]|$|[^a-zA-Z0-9_.\\-])';
const FORBIDDEN_PATTERNS = [
  new RegExp(BOUNDARY + '\\.trash' + END, 'i'),
  new RegExp(BOUNDARY + '\\.qoder' + END, 'i'),
  new RegExp(BOUNDARY + '\\.env(?:\\.|$|[^a-zA-Z0-9_.\\-])', 'i'),
  /(^|[\\\/\s'"])report_[^\s'"\\\/]*\.(xlsx|csv|parquet)\b/i,
];

function readStdin() {
  return new Promise((resolve) => {
    let buf = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => (buf += chunk));
    process.stdin.on('end', () => resolve(buf));
  });
}

function offendingMatch(value) {
  if (typeof value !== 'string') return null;
  for (const re of FORBIDDEN_PATTERNS) {
    if (re.test(value)) return value;
  }
  return null;
}

function scanToolInput(toolInput) {
  // Common fields across Read/Edit/Write/Glob/Grep/Bash/NotebookEdit.
  const candidates = [
    toolInput.file_path,
    toolInput.path,
    toolInput.pattern,
    toolInput.notebook_path,
    toolInput.command,
  ].filter((x) => typeof x === 'string');

  // MultiEdit has an `edits` array; iterate.
  if (Array.isArray(toolInput.edits)) {
    for (const e of toolInput.edits) {
      if (typeof e?.file_path === 'string') candidates.push(e.file_path);
    }
  }

  for (const c of candidates) {
    const hit = offendingMatch(c);
    if (hit) return hit;
  }
  return null;
}

(async () => {
  const raw = await readStdin();
  let payload;
  try {
    payload = JSON.parse(raw || '{}');
  } catch {
    // If the harness sends malformed JSON, fail-open — we don't want to break
    // every tool call because of a parse error.
    process.exit(0);
  }

  const toolInput = payload.tool_input || {};
  const offender = scanToolInput(toolInput);

  if (offender) {
    const tool = payload.tool_name || 'tool';
    process.stderr.write(
      `🚫 Blocked: ${tool} attempted to access "${offender}".\n` +
        `   Path is protected by .claude/hooks/protect-trash.cjs (SPEC §5).\n` +
        `   To use this file, move it out of the excluded area first.\n`,
    );
    process.exit(2);
  }

  process.exit(0);
})();
