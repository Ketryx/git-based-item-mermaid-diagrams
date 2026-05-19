---
name: mermaid-sidecar
description: Maintain the sidecar .mmd/.svg convention for mermaid diagrams in Ketryx git-based markdown items. Trigger when authoring or editing .md or .mmd files in repos that follow this pattern (sidecar mermaid source + committed SVG, no inline ```mermaid``` blocks in .md).
---

# Mermaid sidecar convention

In this repo, mermaid diagrams live as **sidecar `.mmd` source files** next to the `.md` items, with a committed `.svg` rendered from each `.mmd` by `mmdc`. The `.md` references the `.svg` via a plain image link.

**Never** put raw ```` ```mermaid ```` blocks in committed `.md` files — they don't render in Ketryx-generated documents.

## Detect the convention

This convention is active if any of these are present:
- `Makefile` whose targets call `mmdc`.
- `@mermaid-js/mermaid-cli` in `package.json`.
- `.mmd` files committed next to `.md` files.

## Adding a diagram

1. Create `<item-name>.mmd` next to the `.md` item with the raw mermaid source. Use a suffix for multiple diagrams per item: `spec-foo-flow.mmd`, `spec-foo-state.mmd`.
2. Run `make` to generate `<item-name>.svg`. (Or: `./node_modules/.bin/mmdc -i <name>.mmd -o <name>.svg --outputFormat svg --quiet`)
3. In the `.md` item, add the image link: `![Caption](<item-name>.svg)`.
4. Stage all three files (`.mmd`, `.svg`, `.md`) in one commit.

## Editing a diagram

1. Edit the `.mmd` file — never the `.svg`.
2. Re-render via `make`.
3. Stage both the `.mmd` and updated `.svg`.

## Anti-patterns to avoid

- Inline ```` ```mermaid ```` blocks in committed `.md` files (won't render in Ketryx).
- Hand-editing `.svg` files (will be overwritten; `make check` flags it).
- Renaming a `.mmd` without renaming its `.svg` and updating every `.md` link.

## Before finishing a task

- Every `.mmd` you edited has a fresh matching `.svg`.
- `make check` exits 0.
- Every `.md` image link points at a file that exists.
