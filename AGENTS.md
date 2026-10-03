# Nở / Bloom

Read `docs/README.md`, the relevant feature spec, and `tasks/plan.md` before implementation. Product is **Nở**; Kaneo project is **Bloom**. User-facing copy is Vietnamese. Do not hard-code the pilot user's name for other accounts.

## Non-negotiable

- Flutter + SQLite/Drift on device; Spring Boot + PostgreSQL on server.
- Core study, grading, scheduling, saved progress, cached audio, rose state and reminders must work offline. Ship a bundled starter pack.
- Persist locally before confirming an answer. Idempotent sync; no silent loss of pending data or account mixing.
- AI is optional online assistance, not a prerequisite or authoritative SRS grade.
- Content teaches sense + usage pattern; do not reduce the product to word/translation flashcards.

## Execution

- Kaneo owns task status when connected. `docs/backlog.json` is a specification/export snapshot, not a second live task board. Check `docs/kaneo-map.json` for verified IDs and publication state.
- Take an atomic task, inspect dependencies, implement and verify its acceptance criteria, then report evidence. Do not claim Done based solely on a successful build.
- Follow `docs/offline-sync.md` and `docs/quality-release.md`. Pin actual build/test commands after scaffolding; no application exists at initial documentation commit.
- Keep migrations coordinated, content revisions immutable, and API changes reflected in `contracts/`.
- No secrets, recordings, private learner sentences or production credentials in commits/logs.
- Do not deploy publicly, publish a Play release, or send external messages unless authorized for that action. Creating planning tasks in Bloom is authorized.
- Do not start agents automatically; only delegate when explicitly requested or otherwise explicitly authorized by applicable instructions.

## Scope

Android MVP first. No microservices, payments, full VSTEP test platform, or live voice tutor in the initial backlog. Report material scope changes rather than silently weakening offline guarantees.
