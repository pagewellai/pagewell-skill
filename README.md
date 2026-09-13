# pagewell

The [PageWell](https://pagewell.ai) skill for coding agents, and the CLI it
drives. An agent with this skill can write a document that looks designed — an
article, a résumé, a report, a handbook — or a single-page interactive
artifact, check it against the template's own rules, and publish it as a link:
a page of its own at `p.pagewell.ai/s/…`, a share link, a share code, or a
single HTML file that opens offline.

## Install the skill (Claude Code)

```bash
git clone https://github.com/pagewellai/pagewell-skill ~/.claude/skills/pagewell
~/.claude/skills/pagewell/scripts/install.sh
```

This repository **is** the skill — `SKILL.md` sits at its root and the
`references/` next to it are what the agent loads on demand. Any agent that
reads `SKILL.md`-style skills can use the same clone; the CLI it calls is the
one the installer puts on your `PATH`.

To update, `git pull` in that directory and run the installer again — the
skill text and the binary are published together and always match.

## Install only the CLI

```bash
curl -fsSL https://raw.githubusercontent.com/pagewellai/pagewell-skill/main/scripts/install.sh | bash
```

The installer reads `uname`, picks the matching binary from `bin/`, verifies
it against `bin/SHA256SUMS`, and only then makes it executable. Nothing else
is downloaded and nothing is compiled.

| Platform | Binary | Size |
|---|---|---|
| darwin/amd64 | `pagewell_darwin_amd64` | 12M |
| darwin/arm64 | `pagewell_darwin_arm64` | 11M |
| linux/amd64 | `pagewell_linux_amd64` | 11M |
| linux/arm64 | `pagewell_linux_arm64` | 11M |
| windows/amd64 | `pagewell_windows_amd64.exe` | 12M |
| windows/arm64 | `pagewell_windows_arm64.exe` | 11M |

## First run

```bash
pagewell doctor                       # installed? reachable? signed in?
pagewell templates list --kind doc    # what kinds of page there are
pagewell templates use article -o draft.md
pagewell check draft.md               # the template's own rules, offline
pagewell preview                      # the page as it will render, offline
pagewell auth login                   # a device code; approve it in your browser
pagewell publish draft.md             # one link back
```

Writing, checking, previewing and exporting need no account and no network.
Signing in is only for publishing, and the agent never approves the device
code or completes a payment for you — both happen in your own browser.

## Where things are explained

| | |
|---|---|
| `SKILL.md` | the whole normal flow, written for the agent |
| `references/cli.md` | every command, flag and JSON shape |
| `references/errors.md` | the error codes (a fixed enum, never translated) |
| `references/templates.md` | picking, writing and changing a template |
| [pagewell.ai/docs](https://pagewell.ai/docs) | the product documentation |
| [pagewell.ai/pricing](https://pagewell.ai/pricing) | plans and limits |

## This is a build artifact

There is no source code here. Everything in this repository is generated from
the `pagewell` repository and replaced wholesale on every publish, so a patch
sent here cannot survive the next one. `MANIFEST` records the exact source
commit each file was built from.

Issues and pull requests belong upstream.

| | |
|---|---|
| Version | `8244ec3` |
| Source commit | `8244ec3d7418125b83b54810ce51dff2a3192678` |
| Published | 2026-09-13T03:59:29Z |
