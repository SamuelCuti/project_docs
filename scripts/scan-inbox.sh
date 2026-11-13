#!/usr/bin/env bash
# Scans raw notes for patterns that look like sensitive data, BEFORE an agent processes them.
# Read-only: it never changes a file.
# It prints the file, the line number and the TYPE of data found, never the data itself.
# It cannot detect everything (for example, names of people): a person must still read the notes.
#
# Usage: bash scripts/scan-inbox.sh [file ...]
#        Without arguments it scans every file in inbox/.
# Exit code: 0 = nothing found, 1 = possible sensitive data found, 2 = usage error.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

files=()
if [ $# -gt 0 ]; then
  for f in "$@"; do
    [ -f "$f" ] || { echo "ERROR: file not found: $f" >&2; exit 2; }
    files+=("$f")
  done
else
  for f in inbox/*; do
    [ -f "$f" ] && files+=("$f")
  done
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "No files to scan in inbox/."
  exit 0
fi

# Each pattern is "type<TAB>grep -E regex<TAB>flags". Flags: "i" = ignore case.
# Numbers are handled separately below (they need a digit count).
patterns=(
  $'email\t[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\t'
  $'credential keyword\t(contrase(ñ|n)a|password|passwd|api[ _-]?key|token|secret|credencial)\ti'
  $'ID or salary keyword\t(salario|sueldo|c(é|e)dula|pasaporte|\\b(rut|dni|nif|nie|curp|nss)\\b)\ti'
  $'monetary amount\t(\\$ ?[0-9]|\\b(USD|EUR|CLP|MXN|COP|ARS|PEN) ?[0-9]|[0-9] ?(€|\\b(USD|EUR|CLP|MXN|COP|ARS|PEN)\\b))\ti'
)

findings=()

for file in "${files[@]}"; do
  for entry in "${patterns[@]}"; do
    IFS=$'\t' read -r type regex flags <<< "$entry"
    opts=(-nE)
    [ "$flags" = "i" ] && opts=(-niE)
    while IFS=: read -r line _; do
      findings+=("$file:$line: $type")
    done < <(grep "${opts[@]}" -- "$regex" "$file")
  done

  # Numbers with 7 or more digits (phone, ID, account or card numbers). ISO dates are ignored.
  while IFS=: read -r line match; do
    digits=${match//[^0-9]/}
    [ ${#digits} -ge 7 ] || continue
    [[ "$match" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && continue
    findings+=("$file:$line: phone, ID, account or card number")
  done < <(grep -noE -- '\+?[0-9][0-9 ().-]{5,}[0-9]' "$file")
done

echo "Scanned ${#files[@]} file(s)."
if [ ${#findings[@]} -eq 0 ]; then
  echo "No sensitive-data patterns found."
  echo "Reminder: this scan cannot detect names of people. Read the notes before processing them."
  exit 0
fi

echo "Possible sensitive data (type only, the data is not printed):"
printf '%s\n' "${findings[@]}" | sort -t: -k1,1 -k2,2n -k3 -u | sed 's/^/  /'
echo "Review these lines. A person (never an agent) removes or replaces real data before an agent runs."
echo "Reminder: this scan cannot detect names of people. Read the notes before processing them."
exit 1
