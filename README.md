# Git-based item mermaid diagrams

A worked example for using [mermaid](https://mermaid.js.org/) diagrams inside Ketryx Git-based configuration items.

## The problem

Ketryx parses Markdown files in your Git repo as configuration items, and includes their content in generated documents (Software Item Specs, Requirements, Test Cases, etc.). However, raw ```` ```mermaid ```` fenced code blocks aren't rendered at document-export time — they appear as code, not as diagrams.

## The pattern

Pre-render mermaid blocks at commit time. The committed Markdown that Ketryx reads contains an image link instead of a raw mermaid block. The original mermaid source stays in a collapsed `<details>` section right next to the image, so it remains editable.

Before:

````markdown
```mermaid
flowchart LR
    A --> B
```
````

After (this is what gets committed and what Ketryx sees):

```markdown
![diagram](.diagrams/abc123def456.svg)
<details><summary>Mermaid source</summary>

​```mermaid
flowchart LR
    A --> B
​```

</details>
```

The transformation runs automatically as a `pre-commit` hook, with a CI safety net.

## What's in this repo

| Path | Purpose |
|---|---|
| `render-mermaid.mjs` | The renderer. Walks `items/`, hashes each mermaid block, writes `items/.diagrams/<hash>.svg`, rewrites the block in-place. |
| `.githooks/pre-commit` | Runs the renderer on staged `.md` files. |
| `.github/workflows/check-mermaid.yml` | CI safety net — runs the renderer in `--check` mode and fails if any file would change. |
| `items/` | Sample Ketryx items (Requirements, Software Item Specs) with mermaid diagrams. |
| `package.json` | Pins `@mermaid-js/mermaid-cli`. |

## Try it locally

```bash
git clone https://github.com/Ketryx/git-based-item-mermaid-diagrams.git
cd git-based-item-mermaid-diagrams
npm install
npm run render        # renders the bundled sample items
```

After `npm run render`, look at `items/req-data-flow.md` — the mermaid block has been replaced with an image link, and the source is now inside a `<details>` element. The SVGs live under `items/.diagrams/`.

To enable the pre-commit hook:

```bash
git config core.hooksPath .githooks
```

(One-time; per clone. The hook is a normal shell script — no `husky` or other tooling.)

## Adopting this in your own repo

1. Copy `render-mermaid.mjs`, `package.json`, `.githooks/pre-commit`, and `.github/workflows/check-mermaid.yml` into your repo.
2. Adjust the `MERMAID_GLOB` env var (or the default `items` constant in `render-mermaid.mjs`) to point at the directory tree where your Git-based items live.
3. Run `npm install` and `git config core.hooksPath .githooks`.
4. Author mermaid blocks in your `.md` items as usual. The hook renders them at commit time.

## How the renderer works

The script is **idempotent** and **content-addressed**:

1. Parse each `.md` file. Find ```` ```mermaid ```` blocks (both raw and already-rendered).
2. SHA-256 the source. The first 12 hex chars become the filename: `.diagrams/<hash>.svg`.
3. Render via `@mermaid-js/mermaid-cli` if the SVG doesn't exist yet.
4. Replace the block with the image link + `<details>` source.
5. If the source inside an existing `<details>` is edited, its hash changes and the block re-renders on the next run. Old SVGs are left in place (a future cleanup pass could prune them).

In `--check` mode, the script renders into a temp directory and exits non-zero if any `.md` file would change. CI uses this to catch contributors who bypassed the local hook.

## Determinism

- `@mermaid-js/mermaid-cli` is **pinned** in `package.json`. Bumping it may produce subtly different SVG output, which CI will flag.
- Mermaid generates randomized IDs inside its SVG output; the script strips them post-render so re-running produces byte-identical files for unchanged input.
- Puppeteer/Chromium is downloaded by `mermaid-cli` on install (~150MB). CI uses Ubuntu runners that already have Chrome available.

## Why SVG and not PNG

SVG diffs cleanly under git (it's text), scales without artifacts, and renders correctly in Ketryx's UI at any zoom level. The trade-off: Microsoft Word's SVG support is inconsistent. If you export Ketryx documents to DOCX and need diagrams rendered, change `--outputFormat svg` to `png` in `render-mermaid.mjs`.

## Ketryx project for this repo

This repo is connected to a demo Ketryx project so you can see the items rendered in the Ketryx UI:

- **Org:** `Mermaid Diagrams Demo` (`KXORG0C6P6F9CE993FS276H12J8RA7P`)
- **Project:** `Mermaid Diagrams` (`KXPRJ5TH12PW0CH9MFBRXV6MQMYWY0X`)
- **Instance:** `demo.ketryx.com`
- **Item glob:** `items/**/*.md`

To re-create the GitHub connection from scratch: in Ketryx, go to *Project Settings → Integrations → GitHub → Add connection*, paste a PAT with `repo` scope, then add this repo and set the item glob to `items/**/*.md`.
