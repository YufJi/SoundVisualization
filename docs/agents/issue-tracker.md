# Issue tracker: Local Markdown

Issues and specs for this repo live as Markdown files in `.scratch/`. GitHub is used only to sync the Git repository; GitHub Issues and PR-based triage are not part of this workflow.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The feature specification is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`
- Ticket filenames start at `01` and use two-digit numbering.
- Each issue has a `Status:` line near the top using a role string from `docs/agents/triage-labels.md`.
- Conversation history is appended under `## Comments` at the bottom of the issue file.

## When a skill says "publish to the issue tracker"

Create a new Markdown file under `.scratch/<feature-slug>/`, creating the directory if needed.

## When a skill says "fetch the relevant ticket"

Read the referenced file. The user will normally provide the path or ticket number directly.

## Wayfinding operations

Used by `/wayfinder`.

- **Map**: `.scratch/<effort>/map.md`, containing notes, decisions so far, and remaining fog.
- **Child ticket**: `.scratch/<effort>/issues/<NN>-<slug>.md`, numbered from `01`.
- **Ticket type**: recorded as `Type: research`, `Type: prototype`, `Type: grilling`, or `Type: task`.
- **Claim**: set `Status: claimed` before starting work.
- **Blocking**: add `Blocked by: NN, NN` near the top; a ticket is unblocked when every listed ticket is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for open, unblocked, unclaimed tickets, ordered by number.
- **Resolve**: add the answer under `## Answer`, set `Status: resolved`, and append a context pointer to `map.md`.
