# .pagewell.yaml

This file **belongs in the repository**. It describes what to publish and where,
and contains no credentials.

```yaml
space: spc_01J8ZQ7K3M4N5P        # target space id or slug
source: docs                      # directory to publish, relative to this file
base: /                           # prefix to mount under inside the space

ignore:                           # in addition to the built-in rules
  - drafts
  - "*.tmp"

locales: [en, zh]                 # multi-language layout: docs/{locale}/…
default_locale: en

share:                            # defaults when creating a share after push
  mode: unlisted                  # public | unlisted | code | password
  expire: 7d
  allow: [copy, print]

endpoint: http://localhost:8787   # local development only
```

Built-in ignores: `.git .svn .hg node_modules .next .nuxt dist build .venv venv
__pycache__ .DS_Store .idea .vscode vendor target .cache .wrangler .pagewell`,
plus everything starting with a dot.

## Where credentials live

```
~/.config/pagewell/credentials.yaml    (mode 0600)
```

`PAGEWELL_CONFIG_HOME` moves it.

⚠️ **Credentials never go in the project directory.** If `.pagewell.yaml`
contains `token:` or `api_key:`, the CLI **refuses to start** and tells you how
to clean it up. The same happens if the project directory contains
`credentials.yaml` or `.pagewell-token`, or if `.env` contains `pw_live_`.

This is not enforced by `.gitignore` — that gets forgotten, gets overridden by
`-f`, and stops applying once someone else clones the repo. One loud failure
beats one silent commit.

If it was already committed, treat it as leaked: **revoke** the token under
Settings → Agent tokens first, then clean the history. `pagewell auth logout`
only deletes the local file; it does not revoke anything server-side.

## Multi-language layout

```
docs/
  en/guide/install.md
  zh/guide/install.md      ← automatically paired with the line above
  en/faq.md                ← single language, a group of one
```

The translation group key is **the relative path with the locale segment
removed**. That is why the structure has to match exactly across languages —
one misplaced directory and nothing pairs up, and the language switcher breaks.

⚠️ Better to ship one language than two with mismatched structure.
