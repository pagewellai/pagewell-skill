# Charts

A ` ```chart ` fenced block is YAML. The server renders it to an inline SVG and
a collapsed data table at ingest time. The page stays `inline`, so a chart
costs you nothing in search indexing.

## The block

````
```chart
type: column            # required
title: Weekly active    # optional, becomes the <figcaption>
unit: k                 # optional, appended to axis labels and table cells
height: 300             # optional, 120–900, default 300
stacked: false          # bar / column / area only
table: true             # default true — see "The data table" below
categories: [Mon, Tue, Wed]
series:
  - name: 2025
    data: [12, 19, 24]
  - name: 2026
    data: [20, 26, 35]
```
````

Single series can skip `series:` entirely:

````
```chart
type: donut
categories: [Public, Unlisted, Code]
data: [48, 22, 30]
```
````

## Types

| `type` | Shape | Use it for |
|---|---|---|
| `column` | vertical bars | comparing a handful of categories |
| `bar` | horizontal bars | comparing categories with long names |
| `line` | polyline | a trend over ordered points |
| `area` | filled line | a trend where the total matters; `stacked: true` for composition over time |
| `pie` | circle | parts of one whole, 2–6 slices |
| `donut` | ring | same, with room for a label in the middle (`unit:` goes there) |
| `scatter` | points | two numeric dimensions; takes `points:` not `data:` |

`scatter` is the one exception to the shape above:

````
```chart
type: scatter
series:
  - name: docs
    points: [[2, 14], [5, 22], [8, 19], [11, 34]]
```
````

`pagewell templates list --json` returns the exact list this build supports under
`charts`. Read it rather than trusting this table if the two disagree.

## What the renderer decides for you

| | |
|---|---|
| **Colours** | Eight palette slots, cycling. They live in CSS, so the same chart is correct in light mode, dark mode and all four themes. You cannot set them. |
| **The value axis** | Starts at zero, and only goes below when the data is negative. A truncated axis exaggerates differences; the renderer will not do it. |
| **Axis labels** | Thinned automatically when they would collide. |
| **Mobile** | Two SVGs are emitted, wide and narrow, and CSS picks one. Never assume the desktop layout is what a phone shows. |

## The data table

Every chart ships a `<details>` table of its own numbers below the figure. It
is not decoration: **it is how search engines, screen readers, `llms.txt` and
"copy as text" read the chart.** An SVG is a picture to all four.

Set `table: false` only when the same numbers already appear in the prose right
next to the chart. Never set it because the table looks untidy.

## Limits and failures

- At most **24 charts per document**. Past that they are not rendered.
- More than **8 series** in one chart makes colours repeat; you get a warning.
- A block that fails to parse becomes a visible error box on the page. **The
  rest of the document still publishes** — one bad chart never costs the author
  the whole page.

Every one of these shows up in `pagewell check --json` and in
`pagewell preview --once --json` under `errors`
or `warnings`, with the document path and the chart's index. Fix the errors
before pushing; a published error box is worse than a missing chart.

## When not to use a chart block

- **Flowcharts, sequence diagrams, Gantt, class diagrams** → enable `mermaid`
  (`libs: [mermaid]` in the front matter) and write a ` ```mermaid ` block. The
  declaration stays in the page for crawlers; the picture needs JavaScript, and
  the library is a download on first open. See `libraries.md`.
- **Formulas** → enable `katex`; use `$…$` inline, a `$$…$$` paragraph, or a
  ` ```math ` block.
- **Interactive charts** (hover, zoom, a map) → enable `echarts`. Say the cost
  first: a chart block here costs nothing, and a bar chart does not need a
  1 MB library.
- **Four numbers** → a table or a sentence reads better than a pie chart.
- **Something the reader manipulates** (a slider, live data) → a ` ```embed `
  block. **Only that block** is not indexed; the rest of the page still is.
  Publishing the whole document as HTML costs you the whole page.
