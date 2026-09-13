# Artifacts

A **kind of page**, not a kind of job. Principle explainers, playgrounds,
converters and comparison boards are all artifacts. The page *is* the thing:
if JavaScript is off, there is no article left to read.

A Claude artifact is the same object in a chat preview. Here it is a file you
check, preview and publish.

## One file

One HTML file, one URL. In-page `#anchors` and in-page state are fine. Another
`.html`, a relative path, or `history.pushState` is a second page — `check`
fails it.

A series is several artifacts (or a `doc` tree). Never one artifact that
pretends to be a site.

## Contract

The sandbox already enforces this. `check` says it before publish:

| Must not | Why |
|---|---|
| `fetch` / XHR / WebSocket / `sendBeacon` | `connect-src 'none'` |
| `<form>` or a password field | no `allow-forms`; the platform refuses credential collection |
| `<script src="https://…">`, remote images | inline, relative, or `/_/lib/…` |
| a second page | relative links have nowhere to go |

State lives in memory. Refresh forgets it. That is the product, not a bug.

`<noscript>` is an **error** if missing. With JS off the reader must still see
the claim (explainers) or what the page does (instruments).

## Classify

**If JS is off, is there still an article?** Yes → `doc`, and put a demo in
`embed` if you need one. No → artifact.

Do not promote "an article plus a widget" into a whole artifact. That throws
away indexing for the prose.

## Write

```
pagewell templates list --json --kind artifact
pagewell templates use principle -o page.html
```

Default to `principle` when they want a mechanism visible. The skeleton is
HTML with `⟦…⟧` and `<meta name="pagewell:kind" content="artifact">`.

Metadata is meta tags, not YAML front matter. `pagewell:template` names the
template; `pagewell:subject` (and other `front:` keys from `inputs`) are how
`check` sees required inputs.

## Check, preview, publish

```
pagewell check page.html --json
pagewell preview
pagewell publish page.html --json
```

Say `render_mode`. It is always `sandbox`. Search engines get the title,
description and extracted text on the reading chrome, not the running page.

## Versus `embed`

`embed` is a block *inside* a document. Use it when the prose is the product
and the running bit is one island. An artifact is when the running bit *is*
the product. At most 4 embeds per document; past that, write an artifact.
