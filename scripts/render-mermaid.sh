#!/usr/bin/env bash
# Walk every .md under items/, extract each ```mermaid``` block to
# .mermaid/<dir>/<basename>/<N>.mmd, render to ...<N>.png via mmdc,
# and rewrite the .md so the block becomes an image link.
#
# Numbering: new blocks are assigned the next free integer in the .mermaid/
# subfolder for that .md, so adding a fresh inline block to an already-rendered
# .md doesn't collide with existing files.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MMDC="$ROOT/node_modules/.bin/mmdc"
PUPPETEER_CONFIG="$ROOT/puppeteer-config.json"

if [ ! -x "$MMDC" ]; then
    echo "mmdc not found at $MMDC — run npm install" >&2
    exit 1
fi

next_free_number() {
    local outdir="$1"
    if [ ! -d "$outdir" ]; then
        echo 1
        return
    fi
    local max=0
    local f
    for f in "$outdir"/*.mmd; do
        [ -e "$f" ] || continue
        local n="${f##*/}"; n="${n%.mmd}"
        if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -gt "$max" ]; then
            max="$n"
        fi
    done
    echo $((max + 1))
}

extract_and_render() {
    local md="$1"
    local rel="${md#$ROOT/}"               # e.g. items/spec-foo.md
    local dir="$(dirname "$rel")"          # e.g. items
    local base="$(basename "$rel" .md)"    # e.g. spec-foo
    local outdir="$ROOT/.mermaid/$dir/$base"

    # Bail early if the file has no raw ```mermaid``` blocks.
    if ! grep -q '^```mermaid[[:space:]]*$' "$md"; then
        return 0
    fi

    local start
    start=$(next_free_number "$outdir")
    mkdir -p "$outdir"

    # awk pass 1: write each block to <start>.mmd, <start+1>.mmd, …
    local count
    count=$(awk -v outdir="$outdir" -v start="$start" '
        BEGIN { n = start - 1; inblock = 0 }
        /^```mermaid[ \t]*$/ { inblock = 1; n++; fname = outdir "/" n ".mmd"; next }
        inblock && /^```[ \t]*$/ { inblock = 0; close(fname); next }
        inblock { print > fname }
        END { print n - start + 1 }
    ' "$md")

    # Render each newly-written .mmd.
    local i
    for ((i=start; i<start+count; i++)); do
        "$MMDC" --input "$outdir/$i.mmd" --output "$outdir/$i.png" \
            --outputFormat png --scale 2 --quiet \
            --puppeteerConfigFile "$PUPPETEER_CONFIG"
    done

    # awk pass 2: rewrite the .md, replacing each block (in encounter order)
    # with an image link pointing at the same N we used in pass 1.
    local depth=$(echo "$dir" | tr -cd '/' | wc -c | tr -d ' ')
    local up=""
    local d
    for ((d=0; d<=depth; d++)); do up="../$up"; done   # one ../ per dir level, plus one for the .md itself
    local link_prefix="${up}.mermaid/$dir/$base"

    awk -v prefix="$link_prefix" -v start="$start" '
        BEGIN { inblock = 0; n = start - 1 }
        /^```mermaid[ \t]*$/ { inblock = 1; n++; print "![diagram](" prefix "/" n ".png)"; next }
        inblock && /^```[ \t]*$/ { inblock = 0; next }
        inblock { next }
        { print }
    ' "$md" > "$md.tmp"
    mv "$md.tmp" "$md"

    local end=$((start + count - 1))
    echo "rendered $count diagram(s) (numbered $start..$end): $rel"
}

# Find every .md under items/ and process it.
while IFS= read -r -d '' md; do
    extract_and_render "$md"
done < <(find "$ROOT/items" -name '*.md' -print0)
