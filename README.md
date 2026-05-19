# Git-based item mermaid diagrams

Render [mermaid](https://mermaid.js.org/) diagrams in Ketryx Git-based configuration items.

Raw ```` ```mermaid ```` blocks don't render in Ketryx-generated documents. Write them inline anyway — when your PR is ready, label it `render-mermaid` and a GitHub Action runs the official mermaid CLI on each `.md`. The CLI extracts each block, renders it to PNG, and rewrites the `.md` to reference the PNG. The bot commits the result to your PR branch.

You author markdown the way you always do. The bot handles the rest.

See it in action: [PR #2](https://github.com/Ketryx/git-based-item-mermaid-diagrams/pull/2) is a permanent demo PR showing a commit with inline mermaid followed by the bot's rendered commit.

## How it works

For `items/spec-foo.md` with one mermaid block, the bot produces `items/spec-foo-1.png` and rewrites the `.md`:

```diff
- ```mermaid
- flowchart LR
-     A --> B
- ```
+ ![diagram](./spec-foo-1.png)
```

If the `.md` has two blocks, the bot produces `spec-foo-1.png` and `spec-foo-2.png`. The `render-mermaid` label stays on the PR as a "rendered" badge.

The whole rendering step is one line:

```bash
find items -name '*.md' -exec ./node_modules/.bin/mmdc -i {} -o {} -e png --scale 2 -q -p puppeteer-config.json \;
```

That's `@mermaid-js/mermaid-cli`'s built-in markdown mode. There's no custom rendering code in this repo.

## Editing a diagram later

The mermaid source for each rendered block lives in git history (the commit that originally added the inline block). To change a diagram, paste the source back into the `.md` as a fresh ```` ```mermaid ```` block, re-apply the `render-mermaid` label, and the bot will re-render.

## Running it locally

```bash
git clone https://github.com/Ketryx/git-based-item-mermaid-diagrams.git
cd git-based-item-mermaid-diagrams
npm install
find items -name '*.md' -exec ./node_modules/.bin/mmdc \
  --input {} --output {} \
  --outputFormat png --scale 2 --quiet \
  --puppeteerConfigFile puppeteer-config.json \;
```

## Adopting in your own repo

Copy:

- `package.json`
- `puppeteer-config.json`
- `.github/workflows/render-mermaid.yml`

Create a label called `render-mermaid` in your repo. Adjust the `find items` path in the workflow if your items live somewhere else.

The Action commits to the PR branch using the default `GITHUB_TOKEN`. This works for PRs from branches in the same repo. PRs from forks won't get auto-rendering — fork contributors run the one-liner locally and commit the rendered output before opening the PR.

## Claude skill

If you use [Claude Code](https://claude.com/claude-code), copy `.claude/skills/mermaid-diagrams/` into your repo. The skill tells Claude to write inline ` ```mermaid``` ` blocks and never hand-author the rendered links.
