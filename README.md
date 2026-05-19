# Git-based item mermaid diagrams

Render [mermaid](https://mermaid.js.org/) diagrams in Ketryx Git-based configuration items.

Raw ```` ```mermaid ```` code blocks don't render in Ketryx-generated documents. Instead, commit a `.mmd` source file and a generated `.svg` next to each item, and reference the `.svg` with a plain image link.

## Quickstart

```bash
git clone https://github.com/Ketryx/git-based-item-mermaid-diagrams.git
cd git-based-item-mermaid-diagrams
npm install                            # installs mermaid-cli at the pinned version
make                                   # renders every items/*.mmd into items/*.svg
git config core.hooksPath .githooks    # enables the pre-commit re-render hook (one-time)
```

Open `items/spec-sensor-state-machine.md` — the image link resolves to the SVG you just generated.

## Authoring a diagram

1. Create `items/<name>.mmd` with the mermaid source.
2. Commit it. The pre-commit hook re-renders the matching `.svg`. (Or run `make` manually.)
3. In the `.md` item, reference the SVG: `![Caption](<name>.svg)`.
4. Commit the `.md`, `.mmd`, and `.svg` together.

**Naming.** One `.mmd` per diagram, named after the item it illustrates.

**Multiple diagrams in one item.** Give each diagram its own `.mmd` and a distinct suffix. For example, `items/spec-build-pipeline.md` has two:

```
items/
├── spec-build-pipeline.md
├── spec-build-pipeline.mmd            ← stage flowchart source
├── spec-build-pipeline.svg
├── spec-build-pipeline-trigger.mmd    ← trigger sequence source
└── spec-build-pipeline-trigger.svg
```

Non-mermaid images (screenshots, photos) live alongside without a `.mmd` — the convention only manages the mermaid ones.

**Editing.** Edit the `.mmd`, never the `.svg`. The pre-commit hook re-renders on stage.

## Adopting in your own repo

Copy:

- `Makefile`
- `package.json`
- `.githooks/pre-commit`
- `puppeteer-config.json`
- `.github/workflows/check-mermaid.yml`

If your items live somewhere other than `items/`, adjust the `find items` path in the `Makefile`. Then run `npm install` and `git config core.hooksPath .githooks`.

For DOCX export, switch `--outputFormat svg` to `png` in the `Makefile` — Word's SVG support is inconsistent.

## Claude skill

If you use [Claude Code](https://claude.com/claude-code), copy `.claude/skills/mermaid-sidecar/` into your repo. The skill teaches Claude to follow this convention when authoring or editing items.
