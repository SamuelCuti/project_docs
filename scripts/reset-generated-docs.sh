#!/usr/bin/env bash
# Resets the generated documents to their empty templates.
# Use it only for tests: it deletes meeting notes and requirements.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "This will DELETE:"
echo " - every .md file in docs/meeting-notes/, docs/adr/, docs/risks/ and docs/learning/"
echo " - docs/requirements/requirements.md"
echo "and RESET to empty templates:"
echo " - docs/glossary.md"
echo " - docs/open-questions.md"
echo "It will NOT touch inbox/, .github/ or scripts/."
read -r -p "Type RESET to continue: " answer
[ "$answer" = "RESET" ] || { echo "Cancelled."; exit 1; }

for dir in meeting-notes adr risks learning; do
  mkdir -p "docs/$dir"
  rm -f docs/"$dir"/*.md
  touch "docs/$dir/.gitkeep"
done
rm -f docs/requirements/requirements.md
mkdir -p docs/requirements
touch docs/requirements/.gitkeep

cat > docs/glossary.md <<'EOF'
# Glosario

Glosario compartido del proyecto. Los términos los agregan el Analyst y el Mentor.
Toda entrada debe ser validada por una persona con experiencia antes de considerarse definitiva.

## Formato de cada entrada

### Término (nombre en inglés)
- **Definición:** significado general del término, en palabras simples.
- **En este proyecto:** cómo se usa aquí, con su fuente (reunión o documento).
- **Estado:** no verificado | validado

## Términos
EOF

cat > docs/open-questions.md <<'EOF'
# Preguntas abiertas

Decisiones y dudas que todavía no se resuelven.
Para cerrar una pregunta, pásala a "Resueltas" y enlaza el ADR o documento que la responde.

## Abiertas

| ID | Pregunta | Fuente | Riesgo | Responsable |
| --- | --- | --- | --- | --- |

## Resueltas

| ID | Pregunta | Respuesta | Referencia |
| --- | --- | --- | --- |
EOF

echo "Done. Generated documents were reset."