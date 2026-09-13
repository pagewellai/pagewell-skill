# What gets indexed, and what does not

Decided **by the server at ingest time**, not guessed by the client. Every node
in the `sync:plan` response carries `render_mode` and `reason` — relay the
`reason` verbatim.

## The rule

| Content | Mode | Consequence |
|---|---|---|
| Markdown, with any template | **always inline** | full SEO, our typography, TOC, copy and print all work |
| Clean HTML (no scripts, forms or iframes) | inline | same |
| HTML containing `<script>`, `on*`, `javascript:`, `<iframe>`, `<form>`, `<object>`, `<embed>`, `<canvas>` | **sandbox** | the whole page runs on a per-user isolated origin; **search engines only get the summary** |

An author can force the sandbox with
`<meta name="pagewell:render" content="sandbox">`. The reverse is not allowed:
HTML with scripts cannot be forced inline. Markdown cannot be forced into the
sandbox — that would throw away indexing for nothing.

## Template CSS no longer costs indexing

In the previous version, any template that carried its own CSS pushed the whole
document into the sandbox. **That is no longer true.** Theme CSS is parsed
against a property whitelist, scoped to the document container, and the
container is `contain: paint; isolation: isolate` — so a stylesheet cannot reach
the page around it. We can prove it safe, so it is inlined.

The result: a template can look designed *and* be indexed. There is no longer a
trade to explain here.

## The one thing that is not indexed, and it is one block

```embed
```

An `embed` block runs on the isolated origin. **The rest of the page is still
inline and still indexed** — that is the whole reason the block exists. Use it
instead of publishing an entire document as HTML.

At most 4 per document. Past that, publish the whole thing as HTML instead and
say what it costs.

## Hosted libraries need JavaScript, but the text survives

A ` ```mermaid ` or ` ```math ` block keeps its **source text in the DOM**. The
picture needs JavaScript; the content does not. Crawlers, screen readers,
`llms.txt` and "copy as text" all get the declaration. Say this rather than
"the diagram is not indexed" — the distinction matters to the author.

## Charts do not send a page anywhere

A ` ```chart ` block is data, not code. It renders to SVG on the server, so a
Markdown page full of charts is still `inline`. **Do not reach for HTML and a
chart library** — that trades away search for nothing. See `charts.md`.

## What works inside the sandbox

- Scripts run, but the CSP sets `connect-src 'none'` — **no network requests at all**
- `form-action 'none'` — forms cannot submit
- The iframe withholds `allow-same-origin`, `allow-top-navigation`, `allow-forms`, `allow-modals`
- Each user gets a distinct subdomain, and the page runs on the **content
  author's** origin — still the original author's after a fork — so forking
  someone's scripted document cannot let their script read your data

## The reading page's own CSP

`default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';
img-src 'self' https: data:; object-src 'none'; base-uri 'self'`.

`'unsafe-inline'` for styles is the design snapshot — CSS we generated from a
validated cascade. `script-src 'self'` is why hosted libraries are hosted by us
rather than fetched from a CDN.

## How to explain it

Default to Markdown and stay there. Charts, components, behaviours, themes,
diagrams and even a live simulator are all available without leaving it. Publish
a whole document as HTML only when it is genuinely one application, and then say:

> This is one interactive app rather than a document, so it runs in an isolated
> sandbox. The link and copying work normally, but search engines will only see
> the summary. Want the explanation as a normal page with the app as an embedded
> block instead? That way the text still gets indexed.

## Hard rules

| Situation | What to do |
|---|---|
| The output contains a `<form>` or a login box | **Refuse to publish** and explain |
| User wants SEO but the content must run code | Offer an `embed` inside a normal document — that is exactly what it is for |
| More than 4 embeds | Suggest publishing as HTML instead, and state the cost |
