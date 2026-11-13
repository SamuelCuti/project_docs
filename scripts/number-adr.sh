#!/usr/bin/env bash
# Prints the next ADR number (four digits) and, if a title is given, the file name to use.
# Read-only: it never creates or changes a file.
#
# Usage: bash scripts/number-adr.sh                     -> 0003
#        bash scripts/number-adr.sh use-synthetic-data  -> docs/adr/0003-use-synthetic-data.md
# Exit code: 0 = ok, 1 = problem found (duplicated numbers, bad or repeated title).
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

nums=()
for f in docs/adr/[0-9][0-9][0-9][0-9]-*.md; do
  base=$(basename "$f")
  nums+=("${base:0:4}")
done

if [ ${#nums[@]} -gt 0 ]; then
  dups=$(printf '%s\n' "${nums[@]}" | sort | uniq -d)
  if [ -n "$dups" ]; then
    echo "ERROR: these ADR numbers are used more than once: $(echo $dups)" >&2
    echo "A person must fix the numbering before a new ADR is added." >&2
    exit 1
  fi
fi

max=0
for n in ${nums[@]+"${nums[@]}"}; do
  value=$((10#$n))
  [ "$value" -gt "$max" ] && max=$value
done

if [ "$max" -ge 9999 ]; then
  echo "ERROR: no four-digit ADR numbers left." >&2
  exit 1
fi
next=$(printf '%04d' $((max + 1)))

if [ $# -eq 0 ]; then
  echo "$next"
  exit 0
fi

title="$1"
if [[ ! "$title" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: the title must be short kebab-case in English (example: use-synthetic-data)." >&2
  exit 1
fi

existing=(docs/adr/[0-9][0-9][0-9][0-9]-"$title".md)
if [ ${#existing[@]} -gt 0 ]; then
  echo "ERROR: an ADR with this title already exists: ${existing[*]}" >&2
  echo "Write a new ADR that supersedes it with a different title, or ask a person." >&2
  exit 1
fi

echo "docs/adr/$next-$title.md"
