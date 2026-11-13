# Project Instructions

## Purpose
This repository is the documentation and decision log for software projects.
It is maintained with the help of four AI agents: Analyst, Architect, Reviewer and Mentor.
People make the final decisions. Agents prepare, question and document.

## Project context
This repository supports the definition and design phase of software projects.
It keeps meeting notes, requirements, architecture decisions and risks in one place.
It is designed to be reusable across several projects.

## Language
- Code, scripts, instructions, folder names and file names: always in English.
- The content of the documents the agents generate (meeting notes, requirements, ADRs, risk reports, glossary entries, open questions): write it in Spanish, including section headings.
- Always reply to the user in Spanish, in the chat.
- Technical terms: keep the English term and explain it in Spanish the first time (example: "linaje de datos (data lineage)").

## Repository structure
- inbox/: raw notes and transcripts not yet processed
- docs/meeting-notes/: structured meeting notes
- docs/requirements/: requirements, each with its source
- docs/adr/: architecture decision records
- docs/risks/: risk reports
- docs/learning/: plain-words explanations of meetings (Mentor)
- docs/glossary.md: shared glossary
- docs/open-questions.md: decisions still pending
- scripts/: deterministic helper scripts

## Naming conventions
- Use kebab-case for files and folders (example: open-questions.md).
- Start meeting notes with an ISO date (example: 2026-11-11-kickoff.md).
- Number ADRs with four digits (example: 0001-use-synthetic-data.md).
- Risk reports use the number of the ADR they review (example: 0001-risk-report.md).
- Learning notes start with an ISO date (example: 2026-11-11-kickoff.md).
- IDs: REQ-001 (requirements), OQ-001 (open questions), RSK-001 (risks, restart in each report).

## Off-limits folders
- samples/: example notes for the human who tests the agents. Never read, search, list, edit,
  copy from or cite anything in samples/. Your only input is what the user names in inbox/ or in docs/.
- __context/: design rationale of the project. Reference for people only; do not read or cite it.
- If the user asks you to use a file from one of these folders, tell them to copy it to inbox/ first.

## Scripts
Deterministic tasks are done by scripts in scripts/. The agents run them themselves with the
terminal, so the user does not have to. Each agent file lists which scripts it may run.
- scripts/scan-inbox.sh: looks for sensitive-data patterns. Run on the notes before processing and on the documents written afterwards.
- scripts/number-adr.sh: prints the next ADR number and file name.
- scripts/validate-docs.sh: checks the fixed formats of docs/. Run after writing documents.
- scripts/reset-generated-docs.sh: deletes generated documents. Tests only, run by a person. No agent may run it.
Agents use the terminal only to run these scripts, as `bash scripts/<name>.sh`. Never to create,
change or delete files, and never for any other command.

## Rules for every agent
1. Do not invent information. Mark gaps as "assumption" or "open question".
2. Traceability: every requirement and decision states its source.
3. Security by default: never request or use real or sensitive data. Use fictional examples.
4. If something is ambiguous, ask before assuming.
5. Use the fixed document formats of this repository.
6. Never approve decisions. A person decides.