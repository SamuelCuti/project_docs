#!/usr/bin/env bash
# Validates the fixed formats of the documents in docs/ (names, required lines and sections, IDs).
# Read-only: it never changes a file. It checks the FORMAT, not whether the content is right:
# a person still reviews the content.
#
# Usage: bash scripts/validate-docs.sh
# Exit code: 0 = no errors (warnings allowed), 1 = at least one error.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
shopt -s nullglob

DATE='[0-9]{4}-[0-9]{2}-[0-9]{2}'
errors=0
warnings=0
checked=0

error() { echo "ERROR  $1: $2"; errors=$((errors + 1)); }
warn()  { echo "WARN   $1: $2"; warnings=$((warnings + 1)); }

# Print a file without carriage returns, backticks and trailing spaces, so checks work with CRLF files.
clean() { tr -d '\r`' < "$1" | sed 's/[[:space:]]*$//'; }

require_line() {  # file, exact line
  clean "$1" | grep -qxF -- "$2" || error "$1" "missing line \"$2\""
}

require_regex() {  # file, regex, description
  clean "$1" | grep -qE -- "$2" || error "$1" "missing $3"
}

require_date() {  # file
  require_regex "$1" "^- \*\*Fecha:\*\* $DATE\$" 'line "- **Fecha:** YYYY-MM-DD"'
}

check_dated_name() {  # file
  local base
  base=$(basename "$1")
  [[ "$base" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]] \
    || error "$1" "name must be YYYY-MM-DD-topic.md in kebab-case"
}

get_source() {  # file -> prints the inbox/ path of the "Fuente" line, or nothing
  clean "$1" | sed -n 's/^- \*\*Fuente:\*\* \(inbox\/[^ ]*\)$/\1/p' | head -n 1
}

check_source() {  # file
  local src
  src=$(get_source "$1")
  if [ -z "$src" ]; then
    error "$1" "missing line \"- **Fuente:** inbox/<file>\""
  elif [ ! -f "$src" ]; then
    warn "$1" "source file $src not found"
  fi
}

check_unique_sources() {  # directory
  local files=("$1"/*.md) d
  [ ${#files[@]} -gt 0 ] || return 0
  while IFS= read -r d; do
    [ -n "$d" ] && error "$1" "$d was processed more than once (two documents with the same Fuente)"
  done < <(for f in "${files[@]}"; do get_source "$f"; done | sort | uniq -d)
}

# ---------- Meeting notes ----------
for f in docs/meeting-notes/*.md; do
  checked=$((checked + 1))
  check_dated_name "$f"
  require_regex "$f" '^# Acta: .+' 'title "# Acta: <tema>"'
  require_date "$f"
  check_source "$f"
  for h in "## Resumen" "## Temas tratados" "## Acuerdos" "## Pendientes" "## Supuestos"; do
    require_line "$f" "$h"
  done
done
check_unique_sources docs/meeting-notes

# ---------- Requirements ----------
f=docs/requirements/requirements.md
if [ -f "$f" ]; then
  checked=$((checked + 1))
  ids=$(clean "$f" | grep -oE '^### REQ-[0-9]{3}:' | grep -oE 'REQ-[0-9]{3}')
  [ -n "$ids" ] || warn "$f" "no requirements found (expected \"### REQ-001: <título>\")"
  for d in $(printf '%s\n' $ids | sort | uniq -d); do
    error "$f" "ID $d is used more than once"
  done
  while IFS=: read -r n _; do
    error "$f" "line $n: a requirement heading must be \"### REQ-NNN: <título>\""
  done < <(clean "$f" | grep -nE '^#+ *REQ' | grep -vE '^[0-9]+:### REQ-[0-9]{3}: .+')
  while IFS=$'\t' read -r id problem; do
    error "$f" "$id: $problem"
  done < <(clean "$f" | awk '
    function flush() {
      if (id == "") return
      if (!d) print id "\tmissing \"- **Descripción:**\""
      if (!s) print id "\tmissing or empty \"- **Fuente:**\""
      if (!e) print id "\t\"- **Estado:**\" must be propuesto or confirmado"
    }
    /^### REQ-[0-9][0-9][0-9]:/ { flush(); id = substr($2, 1, 7); d = s = e = 0; next }
    /^#/ { flush(); id = ""; next }
    id != "" && /^- \*\*Descripción:\*\*/ { d = 1 }
    id != "" && /^- \*\*Fuente:\*\* .+/ { s = 1 }
    id != "" && /^- \*\*Estado:\*\* (propuesto|confirmado)$/ { e = 1 }
    END { flush() }')
fi

# ---------- ADRs ----------
adr_numbers=()
for f in docs/adr/*.md; do
  checked=$((checked + 1))
  base=$(basename "$f")
  if [[ ! "$base" =~ ^([0-9]{4})-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
    error "$f" "name must be NNNN-title.md (four digits, kebab-case)"
    continue
  fi
  num=${BASH_REMATCH[1]}
  adr_numbers+=("$num")
  require_regex "$f" "^# ADR-$num: .+" "title \"# ADR-$num: <título>\" (the number must match the file name)"
  require_date "$f"
  require_regex "$f" '^- \*\*Estado:\*\* (propuesto|aceptado)$' 'line "- **Estado:** propuesto" (or aceptado)'
  for h in "## Contexto" "## Decisión" "## Alternativas" "## Consecuencias" "## Supuestos" "## Fuentes"; do
    require_line "$f" "$h"
  done
  alts=$(clean "$f" | grep -cE '^### Alternativa [0-9]+: .+')
  pros=$(clean "$f" | grep -cE '^- \*\*Ventajas:\*\*')
  cons=$(clean "$f" | grep -cE '^- \*\*Desventajas:\*\*')
  [ "$alts" -ge 2 ] || error "$f" "needs at least two \"### Alternativa N: <nombre>\" (found $alts)"
  if [ "$pros" -lt "$alts" ] || [ "$cons" -lt "$alts" ]; then
    error "$f" "every alternative needs \"- **Ventajas:**\" and \"- **Desventajas:**\""
  fi
  clean "$f" | awk '/^## Fuentes$/ { on = 1; next } /^## / { on = 0 } on && NF { found = 1 } END { exit !found }' \
    || error "$f" "section \"## Fuentes\" is empty"
done
if [ ${#adr_numbers[@]} -gt 0 ]; then
  for d in $(printf '%s\n' "${adr_numbers[@]}" | sort | uniq -d); do
    error docs/adr "ADR number $d is used more than once"
  done
fi

# ---------- Risk reports ----------
for f in docs/risks/*.md; do
  checked=$((checked + 1))
  base=$(basename "$f")
  if [[ ! "$base" =~ ^([0-9]{4})-risk-report(-v[0-9]+)?\.md$ ]]; then
    error "$f" "name must be NNNN-risk-report.md (NNNN = number of the ADR reviewed)"
    continue
  fi
  num=${BASH_REMATCH[1]}
  adr=(docs/adr/"$num"-*.md)
  [ ${#adr[@]} -gt 0 ] || error "$f" "the reviewed ADR $num does not exist in docs/adr/"
  require_regex "$f" "^# Informe de riesgos: ADR-$num( .*)?\$" "title \"# Informe de riesgos: ADR-$num <título>\""
  require_date "$f"
  require_regex "$f" '^- \*\*ADR revisado:\*\* .+' 'line "- **ADR revisado:** docs/adr/<file>"'
  for h in "## Resumen" "## Riesgos" "## Áreas sin hallazgos" "## Lo que no se pudo evaluar" \
           "## Preguntas para la persona" "## Hallazgos bloqueantes"; do
    require_line "$f" "$h"
  done
  ids=$(clean "$f" | grep -oE '^\| *RSK-[0-9]{3} *\|' | grep -oE 'RSK-[0-9]{3}')
  [ -n "$ids" ] || warn "$f" "no risks found in the table (expected rows starting with \"| RSK-001 |\")"
  for d in $(printf '%s\n' $ids | sort | uniq -d); do
    error "$f" "ID $d is used more than once"
  done
  while IFS=$'\t' read -r id sev; do
    case "$sev" in
      alta|media|baja) ;;
      *) error "$f" "$id: Severidad must be alta, media or baja (found \"$sev\")" ;;
    esac
  done < <(clean "$f" | awk -F'|' '/^\| *RSK-/ {
    id = $2; gsub(/ /, "", id)
    sev = tolower($4); gsub(/[* ]/, "", sev)
    print id "\t" sev }')
done

# ---------- Learning notes (Mentor) ----------
for f in docs/learning/*.md; do
  checked=$((checked + 1))
  check_dated_name "$f"
  require_regex "$f" '^# Explicación: .+' 'title "# Explicación: <tema>"'
  require_date "$f"
  check_source "$f"
  for h in "## Resumen en palabras simples" "## Glosario de la reunión" "## Dudas para el experto" \
           "## Mapa de conceptos" "## Supuestos"; do
    require_line "$f" "$h"
  done
  clean "$f" | grep -qF 'Por dónde empezar a estudiar' \
    || error "$f" "the concept map must end with \"Por dónde empezar a estudiar:\""
done
check_unique_sources docs/learning

# ---------- Glossary ----------
f=docs/glossary.md
if [ ! -f "$f" ]; then
  error "$f" "file not found"
else
  checked=$((checked + 1))
  require_line "$f" "## Términos"
  while IFS=$'\t' read -r term problem; do
    error "$f" "\"$term\": $problem"
  done < <(clean "$f" | awk '
    function flush() {
      if (term == "") return
      if (!d) print term "\tmissing or empty \"- **Definición:**\""
      if (!p) print term "\tmissing or empty \"- **En este proyecto:**\" (with its source)"
      if (!e) print term "\t\"- **Estado:**\" must be no verificado or validado"
    }
    /^## Términos$/ { on = 1; next }
    on && /^## / { flush(); term = ""; on = 0; next }
    on && /^### / { flush(); term = substr($0, 5); d = p = e = 0; next }
    on && term != "" && /^- \*\*Definición:\*\* .+/ { d = 1 }
    on && term != "" && /^- \*\*En este proyecto:\*\* .+/ { p = 1 }
    on && term != "" && /^- \*\*Estado:\*\* (no verificado|validado)$/ { e = 1 }
    END { flush() }')
  while IFS= read -r d; do
    [ -n "$d" ] && error "$f" "term \"$d\" appears more than once"
  done < <(clean "$f" | awk '/^## Términos$/ { on = 1; next } on && /^## / { on = 0 } on && /^### / { print substr($0, 5) }' \
           | sort -f | uniq -di)
fi

# ---------- Open questions ----------
f=docs/open-questions.md
if [ ! -f "$f" ]; then
  error "$f" "file not found"
else
  checked=$((checked + 1))
  require_line "$f" "## Abiertas"
  require_line "$f" "## Resueltas"
  ids=$(clean "$f" | grep -oE '^\| *OQ-[0-9]{3} *\|' | grep -oE 'OQ-[0-9]{3}')
  for d in $(printf '%s\n' $ids | sort | uniq -d); do
    error "$f" "$d appears more than once (a question is in Abiertas OR in Resueltas, once)"
  done
  while IFS=$'\t' read -r id problem; do
    error "$f" "$id: $problem"
  done < <(clean "$f" | awk -F'|' '
    /^## Abiertas$/ { section = "open"; next }
    /^## Resueltas$/ { section = "closed"; next }
    /^## / { section = ""; next }
    /^\| *OQ-/ {
      id = $2; gsub(/ /, "", id)
      col4 = $4; gsub(/ /, "", col4)
      col5 = $5; gsub(/ /, "", col5)
      if (section == "open" && col4 == "") print id "\tempty Fuente"
      if (section == "closed" && col5 == "") print id "\tempty Referencia (link the ADR or document that answers it)"
    }')
fi

echo "Checked $checked file(s): $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ]
