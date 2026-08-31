# Domain Docs

How engineering skills should consume this repository's domain documentation.

## Before exploring, read these

- `CONTEXT.md` at the repository root.
- `docs/adr/`: read architecture decisions that touch the area being changed.

If either does not exist yet, proceed silently. Domain-modeling creates them lazily once a term or decision is actually resolved.

## File structure

This is a single-context repository:

```text
/
├── CONTEXT.md
├── docs/
│   ├── adr/
│   └── agents/
└── Sources/
```

## Use the glossary's vocabulary

When output names a domain concept, use the term defined in `CONTEXT.md`. Do not drift to synonyms that the glossary explicitly avoids.

If a concept is not yet in the glossary, treat that as a signal to reconsider the language or resolve it through domain modeling.

## Flag ADR conflicts

If proposed work contradicts an existing ADR, surface the conflict explicitly instead of silently overriding the prior decision.
