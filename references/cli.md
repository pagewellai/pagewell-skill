# CLI reference

Every command takes `--json` and `--endpoint`. The `--json` shape is stable and
error codes are a fixed enum that is **never translated**.

## doctor

```
pagewell doctor [--skill-version vMAJOR.MINOR.PATCH] [--json]
```

The skill always runs this first on every activation and passes its own
published `metadata.version` through `--skill-version`; checking is automatic,
read-only, and does not wait for a user request. Returns
`{version, endpoint, reachable, authenticated,
project_config, credentials_path, update, skill_update?}`.
If `reachable` is false, check `--endpoint` before anything else.

`update` is `{current, latest, min, available, required}`: `available` means a
newer release exists; `required` means this copy is older than the oldest
version still supported — commands keep working, but upgrade before going on.
`latest` is absent when the server has not looked yet; then nothing is implied.

`skill_update`, when present, is `{current, latest, available, command?}`. It
compares the activated SKILL.md with the newer of the running CLI and the
published release. When `available` is true, run `command` and re-read SKILL.md.
For the global install shown in the README the command is
`npx skills update pagewell -g -y`.

## upgrade

```
pagewell upgrade [--check] [--force] [--json]
pagewell version [--json]
```

Updates to the latest release. When the skill was installed by `git clone`,
it fast-forwards that clone and re-runs its `scripts/install.sh`, so **SKILL.md
and the binary move together**; the result says `skill_changed: true` when the
skill text or references changed — re-read them before continuing. Otherwise it
downloads the binary for this machine (from the repository's `binaries` branch),
verifies it against `SHA256SUMS`, and replaces itself; the result then says
`method: "binary"` and, when the skill text still needs refreshing, `skill_update`
holds the command that does it — `npx skills update pagewell -g -y` for a skill
installed with `npx skills add`. Run it, then re-read SKILL.md.

If an older CLI rejects `--skill-version`, upgrade the CLI and repeat `doctor`.
That is the only bootstrap exception; released current versions always report
both update states in one request.

`--check` only reports (`{current, latest, min, available, required}`) and
never changes anything. Versions are semver tags (`v0.3.1`); `version` prints
the running one.

You do not need to poll: every command that reaches the server is told the
current version in the response, and once a day (every run when below the
supported floor) a line goes to **stderr** — stdout stays JSON under `--json`.
`PAGEWELL_NO_UPDATE_NOTICE=1` silences it.

## auth

```
pagewell auth login  [--scopes …] [--name …] [--wait=false] [--json]
pagewell auth status [--json]
pagewell auth logout [--json]
```

`--scopes` defaults to `space:read,space:write,share:manage,billing:read`.
**There is no `billing:write`** — it does not exist, and agents must not complete
payments. `config:manage` has to be asked for explicitly.

`--wait=false` prints the verification URL and user code and exits, so you can
hand them over first and poll later. Read both out, then wait:

> Open **pagewell.ai/device** and enter **WDJH-4KQP**. I'll wait here.

⛔ **In either mode, never approve on the user's behalf.** Do not open a browser
and click confirm, do not ask for or fill in any credential. Approval happens in
the user's own browser, always. It is also enforced: the approval endpoint only
accepts a session cookie, and you only have a bearer token.

Once you have an identity, **say whose it is before the first write** —
"Signed in as liu@example.com (8.8 GiB free)". People with more than one account
really do push to the wrong space, and one sentence prevents it.

`auth logout` only deletes the local credential file. To actually **revoke** a
token (say you suspect it leaked), the user revokes it under
Settings → Agent tokens.

## init

```
pagewell init [--source .] [--space <id>] [--title <name>] [--json]
```

Targets an existing Space, or creates one when `--space` is omitted. Spaces
require Pro. Writes `.pagewell.yaml` and **never writes a credential into it**.

## publish

```
pagewell publish <file|-> [--space id] [--title t] [--path p]
                          [--visibility public|unlisted|code|password] [--password …]
                          [--expire 7d] [--allow copy,print]
                          [--extract-assets=false] [--no-share] [--json]
```

One file in, one link out. Unless `--space` is explicit, it writes to the
account's internal **Documents** container, which is not shown as a Space;
uploads; and makes the page public/searchable. Pass `--space` only when a Pro
owner explicitly wants the page inside one. `.pagewell.yaml` does not redirect
this one-file command into a Space. `-` reads standard input, which is
what you want when the document is a string you just produced rather than a file
on disk; with `-` the format defaults to HTML, so pass `--path draft.md` for
Markdown.

`--extract-assets` (on by default, HTML only) pulls inline `data:` images over
1 KiB out into content-addressed files. A generated page usually carries four or
five of them; leaving them inline costs the document's 5 MiB budget and makes
every edit re-download all of them.

The `--json` carries `render_mode` and `reason` — **read them out**. An HTML page
with a `<script>` runs sandboxed, so search engines see the summary only.

`--visibility` defaults to `public`. It is a permanent document setting, not a
share: it has no password, expiry or per-link permissions, and the command
returns the stable `public_url`. `--visibility unlisted|code|password` first
keeps the page itself private and then creates the requested share. `--no-share`
uploads and pins the page private.

**Public pages already have an address.** Every space has a permanent public
address (`address_url` on the space, `/s/<8 chars>`), and every page that is
currently public has its own: `public_url` on the node, `/s/<32 letters>` — no
space, no path in it, so renaming or moving the page never breaks the link.
A space the owner has set to **public** is readable at its address with no share
at all, and its pages show up on Explore. `publish` defaults the page itself to
public even inside a private Space and prints the page's own address
(`"visibility": "public", "searchable": true` in JSON). HTML artifacts remain
sandboxed, so search engines index their title and summary rather than the
iframe body.

**When a page has no address.** In a public space a page can still lack a
`public_url`: either the owner set that one page private, or PageWell **took it
down** (moderation). A taken-down page answers 404 at every address and every
share, and the owner sees the reason in their workbench. You can still push and
edit it; you cannot route around it — do not create a share for it and call the
problem solved.

## visibility

```
pagewell visibility <node-id> public|private|inherit [--json]
```

Changes one existing document without changing its content. `public` returns
the stable public URL and makes the page eligible for Explore, public profiles,
sitemaps and search indexing. `private` pins it private; `inherit` follows the
space again. This is audited and requires `space:write`.

This is `init` + `push` + `share create` with the parts that only make sense for
a directory removed. For a tree you keep in sync, use those three.

## push

```
pagewell push [--dry-run] [--prune] [--yes] [--assets]
              [--source …] [--space …] [--base /] [--idempotency-key …] [--json]
```

- `--dry-run` runs stage one only (`sync:plan`) and **writes nothing at all**.
  The output carries `diff`, `usage` (preflight), `nodes[]` (with the path the
  *server* resolved), `needs_confirmation` and `deleted_paths`.
- `--prune` removes pages that exist remotely but not locally. It is a **soft
  delete** — they go to the space's trash, where the owner can put them back
  from the console (kept 7 days on Free, 30 on Pro, then collected). When
  anything would be deleted you must also pass `--yes`, and the error lists the
  exact paths first.
- `--idempotency-key` **must be reused across retries of the same logical push**,
  otherwise a retry becomes a second commit.
- `--assets` uploads images and other non-document files too. They do not become
  pages: they are counted separately in the diff (`files`), and a document
  reaches them by the relative path it writes. See `assets.md`.

After a successful push the CLI re-runs the plan, because by then the server has
ingested the content and can report each page's `render_mode` — which is exactly
what you need to relay to the author.

## share

```
pagewell share create [--mode unlisted|code|password]
                      [--expire 7d] [--allow copy,download,fork,print,source]
                      [--password …] [--node <id>] [--space <id>] [--json]
pagewell share list   [--json]
pagewell share revoke <id> [--json]
```

`--allow ""` and omitting `--allow` are **not the same thing**: the first means
"explicitly turn every extra permission off", the second means "use the config
default".

`source` lets readers open the **source file** — the Markdown or HTML exactly as
written — from the page's ⋯ menu (`?as=source`). It is off unless the author
turns it on, here or under "Readers may" in the space settings; `copy` alone
does not expose it.

`--mode password` without `--password` generates a readable one and reports it.

### Which mode for which phrasing

| The user said | Mode |
|---|---|
| "public", "put it online", "let people find it" | `pagewell visibility <node-id> public` (not a share) |
| "for my team", "internal", "don't index it" | `--mode unlisted` |
| "a share code", "a passphrase" | `--mode code` |
| "put a password on it" | `--mode password --password <generate one and report it>` |

No expiry mentioned → use the config default; if there is none, `7d`, and say so.

"Don't let them copy it" → `--allow ""`, **and you must add**: this only hides
the buttons. It cannot stop anyone copying — the content is in the DOM. Never
imply otherwise; a false security promise is worse than no feature.

### Handing the link over

**Share codes are 6 characters and case-sensitive** (e.g. `7kMp2Q`). Give the
whole thing as one copyable block, and never change the case of a code —
any normalisation anywhere collapses the code space from 56⁶ to 32⁶.

```
https://p.pagewell.ai/s/7Q2MX9KD3VWZGH5N4TBPQR8S6C
Share code 7kMp2Q (case-sensitive) · valid 7 days · copying allowed
```

Three shapes of address live under `/s/`, and the length tells them apart:
a **share** is 26 characters (the link *is* the key, so it stays long), a
**page's own address** is 32 letters (`public_url`, only for public pages), a
**space's address** is 8 characters (`address_url`, opens the tree of a public
space). Never shorten or "clean up" any of them.

`share list` **does not return share codes** — the server does not send them.
A leaked listing should not equal a leak of every code.

## usage / tree / spaces

```
pagewell usage  [--files N] [--json]   # broken down: documents / files / trash
pagewell tree   [--space …]  # the remote tree
pagewell spaces              # list spaces
```

`usage --files N` adds the N largest files, which space each is in, and whether
any document still references it. That last column is the one that tells you
what is safe to delete. Over quota, the list is added automatically.

`pending cleanup` is space already freed and waiting for the nightly
collection — the answer to "I deleted things and nothing changed".

## preview

```
pagewell preview [--source DIR] [--port 4321] [--template ID] [--variant V]
                 [--once] [--open] [--json]
```

Renders the tree locally, with the same code the server uses, and serves it.
**No network and no sign-in.**

`--once` renders, reports and exits — this is the agent-facing mode. It exits
**non-zero when anything failed to render**, so a failed publish can be caught
before it happens without parsing the output.

The `--json` shape:

```json
{"root": "docs", "docs": 12, "charts": 4, "resumes": 1, "word_count": 8130,
 "templates": {"manual": 11, "magazine-article": 1},
 "themes":    {"manual": 11, "magazine-article": 1},
 "pages": [{"rel_path": "guide/intro.md", "url": "/guide/intro", "title": "…",
            "template": "manual", "theme": "manual",
            "template_ref": "manual@2.0.0", "variant": "", "libs": ["mermaid"],
            "format": "markdown", "render_mode": "inline",
            "charts": 1, "embeds": 0,
            "word_count": 640, "reading_minutes": 3, "bytes": 4210,
            "issues": [{"rule": "length", "severity": "warn",
                        "where": "h2 #4 \"Why it happens\"",
                        "message": "1420 chars; this template wants at most 900",
                        "fix": "split the section, or move detail into a list"}]}],
 "skipped": [{"path": "…", "reason": "…"}],
 "errors":   [{"doc": "guide/intro.md", "kind": "chart",    "message": "…"}],
 "warnings": [{"doc": "guide/intro.md", "kind": "template", "message": "…"}]}
```

`issues[]` is the structured form: a rule name, a location and usually a fix.
`errors[]` and `warnings[]` carry the same problems as flat strings — CLIs and
agents already installed elsewhere read those, so both are filled.

`theme` / `themes` are the old names for `template` / `templates` and carry the
same values. Prefer the new ones; the old ones stay because CLIs already
installed elsewhere read them.

`errors` means something did not render — fix and re-run before pushing.
`warnings` means it rendered but probably not as intended: an unknown template
or variant name, a section outside the length the template asks for, a
` ```mermaid ` block whose library is not enabled, more chart series than
palette colours, an HTML document whose isolated origin local preview cannot
reproduce.

⚠️ **Preview only knows templates installed on this machine.** A marketplace
template that is not installed falls back to the default design — and the
report says so as a warning. Run `pagewell templates add <id>` first.

Without `--once` it serves on `127.0.0.1:4321` and the page reloads itself when
files change. **The port is never chosen automatically** — if it is taken the
command fails and says so, because an address you printed that does not match
the one the user opened is the worst kind of confusion.

What is shared with the published page: the document body, the stylesheet, the
design snapshot, the components, the charts. What is not: the chrome around it.
Preview has a template picker, a variant picker and a banner; it has no share
links, no fork, no permissions. Do not tell the user a preview URL is
shareable — it is bound to their machine.

`embed` blocks do not run in local preview: they need an isolated registrable
origin with a signed URL, which a laptop cannot produce. The poster and title
are shown instead, and the report says so. Pretending they run would be worse
than saying they do not — whether the isolation actually holds is only knowable
after deploying.

## templates

```
templates list [--kind theme|pack|doc|artifact] [--category c] [--lang l] [--mine] [--json]
templates show <id> [--full] [--variant v] [--json]
templates use <id> [--variant v] [--title t] [-o FILE] [--json]
templates samples <id> [--source <sample-id>]
templates preview <id> [--variant v]

templates new <id> --kind theme|pack|doc|artifact [--from <builtin-id>] [--dir D]
templates fork <src> <id> [--dir D]
templates fork --from-doc <path> <id> [--dir D]
templates edit <id> [--dir D] [--force]
templates validate <dir|id>
templates diff <id>
templates save <id> [--version v] [--message m] [--visibility private|team|public]
templates publish <id> [--public|--team] | unpublish <id> | retire <id> --yes

templates add <id>
templates remove <id> [--remote --yes]
```

**`show` is the one that matters.** Its `--json` is the tool kit: the writing
brief, the inputs to collect, the skeleton structure, the components this
template resolves to (with a copy-and-paste `syntax` for each), the checks, the
rubric and the samples. Only the components this template actually uses are
included — context is money.

`use` is `add` + `show` + `scaffold` in one call, and writes a skeleton with
`⟦…⟧` placeholders. It refuses to overwrite an existing file.

`validate` loads a working copy, renders every sample and runs the template's
own checks. **It fails on a doc template with no sample** — a template that
cannot demonstrate itself is one nobody will pick. `save` runs the same thing
locally before uploading, so a rejection does not cost you a round trip.

Three locations, and they are different things:

| | Where | What |
|---|---|---|
| cache | `~/.cache/pagewell/templates/<id>@<version>/` | read-only, used for rendering |
| working copy | `~/.pagewell/templates/<id>/` | the editable source (`--dir` overrides) |
| library | server-side, under your account | what `save` uploads |

Working copies are **not** in the project directory: a template follows the
person, not the checkout, and a package should not end up committed to someone
else's repository.

`retire` needs `--yes`: it stops anyone starting a new document with the
template. Documents already using it keep rendering — their design is frozen
into them.

## check

```
pagewell check [<file|dir>] [--template id] [--variant v] [--strict] [--json]
```

Runs the template's checks and nothing else. **No network, no login**, fast
enough to run after every section. Exit code is 1 when there are errors (or,
with `--strict`, warnings too) — branch on that rather than parsing the text.

Each issue carries `rule`, `severity`, `where` and usually `fix`. `where` is a
location you can go to (`h2 #4 "Why it happens"`, `paragraph #7 under "Costs"`).

Errors mean **do not publish**. Warnings are the template's opinion: read them
out to the user rather than silently cutting content to satisfy them.

## export

```
pagewell export <file> --target html [-o FILE]
                       [--inline-images] [--no-inline-libs] [--base-url URL]
```

One HTML file that **opens with no network**: the stylesheet, the design
snapshot and any hosted libraries the document uses are all inside it. It is
therefore large, and the command reports how large.

Local images are embedded as data URIs by default — a file that needs its images
to travel beside it is not a file that "opens with no network".
`--inline-images=false` keeps it small instead, and `--base-url` rewrites the
paths to absolute ones. Either way the command names any relative reference it
could not resolve, including linked attachments, which cannot be inlined and
have to travel with the HTML.

`--target` currently accepts `html`. Other targets are platform code, not
configuration; adding one needs a release.

## brand

```
pagewell brand show [--json]
pagewell brand set <token>=<value> …
pagewell brand clear
```

A set of token overrides applied to **every** document rendered on this machine.
It sits between the template and each document's own front matter, so it changes
colour, type and logo without freezing anyone's layout.

An unknown token name is an error rather than being ignored — a typo that
silently does nothing is how someone concludes the feature is broken.


## themes

```
pagewell themes [--json]
```

The built-in themes plus the chart types. **Superseded by `templates list`**,
which also shows document templates, component packs, hosted libraries and the
token vocabulary. Kept because scripts and older SKILL copies call it; use
`templates list` for anything new.
