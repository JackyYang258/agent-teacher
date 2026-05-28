#!/usr/bin/env bash
# Build the AgentTeacher release archive.
#
# Packages files tracked by git, minus internal-QA and packaging-only paths
# (evals/, .claude-plugin/, dist/, caches). Audits size and required entries
# before writing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-"$ROOT/dist/agent-teacher.zip"}"
PACKAGE_MAX_BYTES="${TEACHER_PACKAGE_MAX_BYTES:-500000}"
PACKAGE_REQUIRED_ENTRY="SKILL.md"

mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"

cd "$ROOT"

MANIFEST="$(mktemp)"
FILTERED_MANIFEST="$(mktemp)"
trap 'rm -f "$MANIFEST" "$FILTERED_MANIFEST"' EXIT

git ls-files > "$MANIFEST"
awk '
  /^evals\// { next }
  /^dist\// { next }
  /^\.claude-plugin\// { next }
  /(^|\/)__pycache__\// { next }
  /\.pyc$/ { next }
  /(^|\/)\.DS_Store$/ { next }
  { print }
' "$MANIFEST" > "$FILTERED_MANIFEST"

if [[ ! -s "$FILTERED_MANIFEST" ]]; then
  echo "ERROR: no files to package. Did you forget to 'git add'?" >&2
  exit 1
fi

zip -q "$OUT" -@ < "$FILTERED_MANIFEST"

entries="$(zipinfo -1 "$OUT")"

if ! printf '%s\n' "$entries" | grep -Fxq "$PACKAGE_REQUIRED_ENTRY"; then
  echo "ERROR: required package entry missing from $OUT: $PACKAGE_REQUIRED_ENTRY" >&2
  exit 1
fi

size_bytes="$(wc -c < "$OUT" | tr -d '[:space:]')"
if (( size_bytes > PACKAGE_MAX_BYTES )); then
  echo "ERROR: package exceeds ${PACKAGE_MAX_BYTES} bytes: ${size_bytes} bytes" >&2
  exit 1
fi

echo "OK: package audit passed (${size_bytes} bytes, limit ${PACKAGE_MAX_BYTES})"
echo "OK: wrote $OUT"
