# Metadata in the files

## Markdown front-matter

```markdown
---
title: Installation
summary: Up and running in three steps
tags: [guide, setup]
icon: 📦
order: 1
template: reference          # a doc template or a theme
variant: warm                # a named set of token overrides, if it has any
libs: [mermaid]              # hosted libraries this document may use
token.accent: indigo         # override one token for this document only
locale: en
translation_group: guide/install
---
```

`template:` takes a **doc template** (`magazine-article`) or a **theme**
(`editorial`). A doc template brings a skeleton, a brief, required inputs and
checks; a theme brings only appearance.

Pin a version with `template: magazine-article@2.1.0`, or follow the major with
`@^2`. **The default is pinned**: a published piece should not change while its
author is asleep.

`libs:` is opt-in per document. Without it, a ` ```mermaid ` block renders as a
code block — deliberately, because a library is a download and who pays for it
should be an explicit decision. See `libraries.md`.

`token.<name>:` overrides one token for this document. Unknown token names are
an error, not a silent no-op — `pagewell templates list --json` returns the
vocabulary.

**Form-mode templates put the whole document in the front matter.** A resume has
no body at all: `name`, `contact`, `sections`, `sidebar` and so on are fields,
and the layout is the template's. The skeleton `templates use` writes lists them.

`title` wins over the filename. `summary` falls back to the first ~200
characters of body text.

`theme:` is the old name for `template:` and still works; if both appear,
`template:` wins. An unknown name falls back to the default and shows up as a
warning in `pagewell check` — a typo in an appearance setting never blocks
publishing.

⚠️ Two things **do** block publishing rather than falling back: a retired
template (it cannot be newly used, though documents already using it keep
rendering), and one that needs a newer render engine (`engine_outdated` — update
the CLI). Both fail loudly on purpose: falling back silently would leave the
author believing they had used it.

## HTML `<meta>`

```html
<title>How binary search discards half</title>
<meta name="description" content="Each step throws half the list away">
<meta name="pagewell:kind" content="artifact">
<meta name="pagewell:template" content="principle">
<meta name="pagewell:subject" content="binary search">
<meta name="pagewell:icon" content="📊">
<meta name="pagewell:tags" content="explainer">
```

`pagewell:kind=artifact` marks a running page: always sandboxed, one HTML file,
checked with the artifact rules. `pagewell:template` names an artifact template
(`principle`) or, for a leftover clean HTML page, a theme. Required inputs from
the template's `inputs.yaml` land as `pagewell:<front>` (here `subject`).

A `doc` is Markdown with YAML front matter. Do not put `<meta>` in Markdown.

Anything prefixed `pagewell:` is extracted (the prefix is stripped and the rest
stored in `meta`), plus the standard `description`.

## Ordering from the filename

```
docs/
  01-install.md      → /install, order 1
  02-configure.md    → /configure, order 2
  10-advanced.md     → /advanced, order 10
```

The number is consumed: **the URL never contains `/01-install`**, but the
ordering intent from the filesystem is preserved. The prefix form is `\d{1,4}`
followed by `-`, `_` or `.`.

## index / README

```
guide/index.md   → /guide       (represents the folder itself, no extra level)
guide/README.md  → /guide
```

## Slugs are the server's job

The client sends the **raw title** and the relative path, nothing else. The
`nodes[].path` in the `sync:plan` response is the canonical path the server
resolved — **read that, do not construct your own**.

Normalising on both sides is guaranteed to drift, and when it does, the path
shown in the dry run is not the path that gets stored.

Slugs preserve Unicode and are not transliterated: `团队手册` becomes
`/团队手册`, not `/tuan-dui-shou-ce`.

## [[wiki-link]]

```markdown
See [[install]] and [[guide/faq|the FAQ]].
```

Linking to a page that does not exist yet is fine (a red link). Once the target
is created, links pointing at it resolve automatically — the documents that
reference it do not need to be pushed again.
