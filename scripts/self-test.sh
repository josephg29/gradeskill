#!/usr/bin/env bash
#
# self-test.sh — verify a grade skill install is healthy before you rely on it.
#
# Checks:
#   1. SKILL.md exists and has valid-looking YAML frontmatter (name + description)
#   2. The HTML report template exists
#   3. All four rubric files exist
#   4. The helper scripts exist and are executable
#   5. The current directory is writable (reports get written to the repo root)
#   6. Node + Playwright availability (informational — only needed for ui/ux)
#
# Usage:
#   scripts/self-test.sh
#
# Exits non-zero if any required check fails.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

pass=0
fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=$((fail+1)); }
note() { printf '  \033[33m•\033[0m %s\n' "$1"; }

echo "grade · self-test"
echo "root: $ROOT"
echo

# 1. SKILL.md frontmatter
echo "Skill definition:"
if [ -f "$ROOT/SKILL.md" ]; then
  first_line="$(head -n 1 "$ROOT/SKILL.md")"
  if [ "$first_line" = "---" ] \
     && grep -qE '^name:[[:space:]]*\S' "$ROOT/SKILL.md" \
     && grep -qE '^description:[[:space:]]*\S' "$ROOT/SKILL.md"; then
    ok "SKILL.md has valid frontmatter (name + description)"
  else
    bad "SKILL.md frontmatter looks malformed (need leading '---', name:, description:)"
  fi
else
  bad "SKILL.md not found"
fi

# 2. Template
echo "Report template:"
[ -f "$ROOT/assets/report-template.html" ] \
  && ok "assets/report-template.html present" \
  || bad "assets/report-template.html missing"

# 3. Rubrics
echo "Rubrics:"
for r in ui backend code ux; do
  [ -f "$ROOT/references/rubric-$r.md" ] \
    && ok "references/rubric-$r.md present" \
    || bad "references/rubric-$r.md missing"
done

# 4. Scripts
echo "Helper scripts:"
for s in detect-project.sh screenshot-ui.js run-ux-flow.js; do
  if [ -f "$SCRIPT_DIR/$s" ]; then
    [ -x "$SCRIPT_DIR/$s" ] && ok "scripts/$s present + executable" || note "scripts/$s present but not executable (chmod +x)"
  else
    bad "scripts/$s missing"
  fi
done

# 5. Writable output dir
echo "Output:"
if touch "$ROOT/.grade-write-test" 2>/dev/null; then
  rm -f "$ROOT/.grade-write-test"
  ok "repo root is writable (reports can be saved here)"
else
  bad "repo root is not writable"
fi

# 6. Node + Playwright (informational)
echo "Optional (ui / ux grading):"
if command -v node >/dev/null 2>&1; then
  ok "node available ($(node --version))"
  if node -e "require('playwright')" >/dev/null 2>&1; then
    ok "playwright available"
  else
    note "playwright not installed — run: npx --yes playwright install chromium --with-deps"
  fi
else
  note "node not found — ui/ux grading will be unavailable (backend/code still work)"
fi

echo
echo "Result: $pass passed, $fail failed."
[ "$fail" -eq 0 ] || exit 1
