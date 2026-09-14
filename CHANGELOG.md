# Changelog

Every entry is a release: a semver tag here and on the source repository, one
binary per platform on the `binaries` branch, and the `SKILL.md` that goes with it. Older CLIs keep working —
the API only ever adds fields — but the newest is what the skill text describes.

## v0.1.1 — 2026-09-14

The skill and the binaries now live on separate branches: main holds the skill text only, binaries holds the prebuilt CLI for the current release. Install with npx skills add pagewellai/pagewell-skill (140 KiB instead of 70 MiB); update the text with npx skills update pagewell and the binary with pagewell upgrade, each of which points at the other. The docs list where to clone for Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot and Windsurf.

Source commit `c33defe`. Update with `pagewell upgrade`.

## v0.1.0 — 2026-09-13

First tagged release. Adds `pagewell upgrade`, an update notice after commands when a newer version exists, `update` in `pagewell doctor`, and the `source` share permission (read the author's Markdown/HTML). Explore now lists spaces as well as pages.

Source commit `415887c`. Update with `pagewell upgrade`.

