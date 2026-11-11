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
- Write all files, code, folder names and documents in English.
- Always reply to the user in Spanish, in the chat.
- When you use a technical term in the chat, explain it briefly in Spanish.

## Repository structure
- inbox/: raw notes and transcripts not yet processed
- docs/meeting-notes/: structured meeting notes
- docs/requirements/: requirements, each with its source
- docs/adr/: architecture decision records
- docs/risks/: risk reports
- docs/glossary.md: shared glossary
- docs/open-questions.md: decisions still pending
- scripts/: deterministic helper scripts

## Naming conventions
- Use kebab-case for files and folders (example: open-questions.md).
- Start meeting notes with an ISO date (example: 2026-11-11-kickoff.md).
- Number ADRs with four digits (example: 0001-use-synthetic-data.md).

## Rules for every agent
1. Do not invent information. Mark gaps as "assumption" or "open question".
2. Traceability: every requirement and decision states its source.
3. Security by default: never request or use real or sensitive data. Use fictional examples.
4. If something is ambiguous, ask before assuming.
5. Use the fixed document formats of this repository.
6. Never approve decisions. A person decides.