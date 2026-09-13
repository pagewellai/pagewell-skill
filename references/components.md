# Components

A component turns a small piece of structured content into a designed block.
Two syntaxes, one dispatch path.

## Which syntax

| Write this | When |
|---|---|
| `:::name` … `:::` | the body is prose — a lead, a callout, a card, a column |
| ` ```name ` + YAML | the body is data — numbers, steps, a table, a chart |

A bare phrase after the name is a **title**: `:::summary Key points`. Anything
with an `=` is parsed as attributes: `:::quote by="Ada" role="Engineer"`.

Nest by adding a colon to the outer fence:

````
::::columns
:::card Before
Three deploys a week, each one a meeting.
:::

---

:::card After
Eleven a day, nobody watching.
:::
::::
````

## The core pack

Every document has these unless its template says otherwise.

| Component | Syntax | Use it for |
|---|---|---|
| `cover` | fence | the opening block: image, kicker, subtitle, byline |
| `lead` | directive | the opening paragraph, set larger |
| `summary` | directive | key points; this is the block people screenshot |
| `highlight` | directive | one idea that must not be missed. One per section |
| `aside` | directive | something the reader may skip |
| `quote` | directive | a pull quote. Lift a sentence from the body, do not write a new one |
| `card` | both | a self-contained idea that survives being screenshotted alone |
| `columns` | directive | two blocks read against each other; stacks on a phone |
| `stats` | fence | 2–6 figures with labels |
| `steps` | fence | an ordered procedure; each step starts with a verb |
| `timeline` | fence | dated entries: history, changelog, roadmap |
| `compare` | fence | exactly two options, row by row. Three is a table |
| `faq` | fence | questions people actually ask |
| `figure` | fence | an image that needs a caption, or one that breaks the measure |
| `gallery` | fence | 2–8 pictures that belong together |
| `profile` | fence | the author |
| `cta` | fence | one action. Never two — a second halves the first |
| `chart` | fence | seven chart types, rendered on the server. See `charts.md` |
| `resume` | fence | a CV inside a longer document |
| `embed` | fence | a block that runs your own code. See `libraries.md` |

`pagewell templates show <id> --json` returns the exact list this template
resolves to, each with a `syntax` you can copy verbatim. **Read that rather
than this table** — a template can add its own.

### The title, once

Fill `cover`'s `title:` and **the cover carries the document title** — the page
stops printing its own heading above it, so the title appears exactly once.
Leave `title:` out and the plain heading is used instead. Either is fine; what
is not fine is writing the title into the body as `# Heading` as well, which
gives the reader the same words twice and is also an error from
`pagewell check` (`count of: h1`).

The same applies to any component whose `component.yaml` declares
`provides: [title]`.

## Props

Every prop is typed and bounded. Wrong type, unknown name, or over the limit →
a visible error box on the page and an error from `pagewell check`. Nothing
fails silently.

| Type | Accepts |
|---|---|
| `string` `text` `date` | plain text, escaped |
| `markdown` `markdown-inline` | Markdown, rendered and sanitised |
| `number` `bool` `enum` | as named |
| `url` | https, mailto, or a site-relative path — **not** http |
| `image` | `asset://<sha>`, https, or a relative path |
| `list` `object` | nested, with their own schemas |

Text inside a fence's YAML is **plain text**, not Markdown. If you need emphasis
or a link, use a directive component instead.

## Writing one

```
components/quote/
  component.yaml
  component.html
  component.css
```

```yaml
name: quote
summary: A pull quote with attribution.
when: One striking sentence from the body. At most one per section.
syntax: both
slot: body          # where :::quote's body goes
label: by           # where a bare phrase after the name goes
props:
  text: { type: markdown-inline, max: 300 }
  body: { type: markdown, max: 600 }
  by:   { type: string, max: 48 }
behavior: reveal    # optional; see below
limits: { per_doc: 12 }
```

```html
<figure class="quote">
  <blockquote>{{{text}}}{{{body}}}</blockquote>
  {{#by}}<figcaption>{{by}}</figcaption>{{/by}}
</figure>
```

- Mustache only: values, presence, iteration, partials. No expressions, no
  functions. A component cannot express anything that runs.
- `{{{ }}}` only takes effect for `markdown` props, which have already been
  rendered and sanitised. A plain string in triple braces is still escaped.
- A list prop `items` also gives you `has_items` — use it for a wrapper that
  should only appear when the list is non-empty.
- CSS is scoped to `.pw-c-<name>` automatically. Write `.quote`, not a prefix.
- The whole output goes through the sanitiser again. `<script>` in a component
  is wasted keystrokes.

**`summary` and `when` are not documentation, they are the interface.** They are
the only thing an agent reads when deciding whether to use your component. A
component with a vague `when` will be used in the wrong places or not at all.

## Behaviours

A component can declare one interaction primitive. The platform implements it;
you do not write JavaScript.

| behavior | Does | Without JavaScript |
|---|---|---|
| `reveal` | fades in on scroll | shown immediately |
| `steps` | one step at a time, keyboard operable | every step, in order |
| `scrolly` | figure sticks, text scrolls, figure changes | figure then all the text |
| `tabs` | tabbed panels | all panels, each with its heading |
| `accordion` | collapsible sections | all expanded |
| `compare` | draggable before/after split | both, side by side |
| `hotspot` | numbered points on an image | image then a numbered list |
| `counter` | numbers count up in view | the final value |
| `carousel` | horizontal paging | all items, in order |
| `lightbox` | click an image to zoom | the image |
| `sticky-toc` | reading progress | an ordinary table of contents |
| `sync` | two blocks highlight together | both, in full |

**Every state is in the DOM.** JavaScript only decides which one is visible,
which is why these cost nothing in search indexing and why they all degrade to
"show everything" under `prefers-reduced-motion`, in print, and with JS off.

Adding a new behaviour needs a release. Using one does not.

## Limits

Every component has a `per_doc` limit. Past it, the block renders as an error
box rather than being dropped — the limits are there to catch a loop that
generated four hundred cards, and a silent drop would hide exactly that.
