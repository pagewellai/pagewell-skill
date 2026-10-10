# Changelog

Every entry is a release: a semver tag here and on the source repository, one
binary per platform on the `binaries` branch, and the `SKILL.md` that goes with it. Older CLIs keep working —
the API only ever adds fields — but the newest is what the skill text describes.

## v0.3.1 — 2026-10-10

Sending articles to X is now a PageWell Pro feature. On Free, pagewell x connect and pagewell x draft stop with plan_required and the pricing link before anything is uploaded; pagewell x draft --dry-run still works on every plan. pagewell x status shows the plan state. A connection made on Pro is kept after a downgrade and can always be disconnected. SKILL: the Sending to X section and the plan_required rule say so.

Source commit `8a5204d`. Update with `pagewell upgrade`.

## v0.3.0 — 2026-10-10

New: pagewell x turns a Markdown file into an X Article draft and never publishes it. x draft (with --dry-run, which sends nothing), x connect, x status and x disconnect. Code, tables, formulas and images become X's native blocks; anything X has no block for is listed in warnings. SKILL: a new 'Sending to X' section; references/cli.md and errors.md cover the commands and the x_not_connected / x_rejected codes.

Source commit `cde94e0`. Update with `pagewell upgrade`.

## v0.2.2 — 2026-10-09

A fenced block is its own declaration: write a `` ```mermaid `` fence (or `` ```math ``, `` ```echarts ``, `` ```abc ``) and it renders, in `pagewell preview` and on the published page alike, with no `libs:` front matter. Inline `$…$` and `$$…$$` math still need `libs: [katex]`. Preview also picks up the reader's second pass: diagrams open full screen, code blocks carry a language label and a copy button, callouts are tinted cards, sub-headings use the heading typeface, and table columns follow their content.

Source commit `4f792fc`. Update with `pagewell upgrade`.

## v0.2.1 — 2026-09-19

Keep the public Skill and CLI bundle aligned with the unified Reader Shell release.

Source commit `d6dd59d`. Update with `pagewell upgrade`.

## v0.2.0 — 2026-09-19

Default publish is public and searchable without a visible Space; standalone reader preferences; automatic skill update checks.

Source commit `a8180c0`. Update with `pagewell upgrade`.

## v0.1.1 — 2026-09-14

The skill and the binaries now live on separate branches: main holds the skill text only, binaries holds the prebuilt CLI for the current release. Install with npx skills add pagewellai/pagewell-skill (140 KiB instead of 70 MiB); update the text with npx skills update pagewell and the binary with pagewell upgrade, each of which points at the other. The docs list where to clone for Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot and Windsurf.

Source commit `c33defe`. Update with `pagewell upgrade`.

## v0.1.0 — 2026-09-13

First tagged release. Adds `pagewell upgrade`, an update notice after commands when a newer version exists, `update` in `pagewell doctor`, and the `source` share permission (read the author's Markdown/HTML). Explore now lists spaces as well as pages.

Source commit `415887c`. Update with `pagewell upgrade`.

