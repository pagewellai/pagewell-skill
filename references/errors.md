# Error codes

The `--json` shape:

```json
{"error": {"code": "quota_exceeded", "message": "…", "hint": "…", "request_id": "…"}}
```

**`code` is a stable enum and is never translated.** Branch on it.
`message` is already localised for the user — show it as is.
`hint` says what to do next and is usually worth relaying verbatim.

| code | Meaning | What to do |
|---|---|---|
| `unauthenticated` | Not signed in, or the token is gone | **Walk through sign-in again.** Do not fail silently |
| `forbidden_scope` | The token lacks this permission | Name the missing scope and ask the user to re-authorise |
| `not_found` | No such object | Confirm with `pagewell tree` or `spaces` first |
| `conflict` | The remote changed, or the plan was already committed | **Do not decide to overwrite.** Show the remote state and ask |
| `validation_failed` | Malformed request | `detail` usually names the offending entry |
| `depth_exceeded` | More than 8 levels deep | Flatten the tree |
| `too_many_nodes` | Space is over its page limit | Split into several spaces |
| `doc_too_large` | A single document exceeds 5 MiB | Try `--assets` to pull images out; if it still exceeds, split it |
| `invalid_html` / `invalid_markdown` | Parse failure | Report which file |
| `rate_limited` | Too fast | Wait. Do not retry immediately |
| `quota_exceeded` | Out of storage | See the order below |
| `plan_readonly` | The account is in a read-only phase | **Nothing has been deleted.** Say so explicitly |
| `plan_required` | The plan does not reach this: a template needs a higher plan, or a Free account hit a limit — Spaces are Pro-only, 20 active shares, 2 agent tokens, or a **password** share | Say what the limit is (the message names it); keep ordinary documents in Documents, for shares or tokens suggest revoking an unused one, and for password shares fall back to `--mode code`; hand over `/pricing` second. **Never complete a payment** |
| `share_expired` | The share is gone | Create a new one |
| `internal` | Server-side failure | Report it with the `request_id` |

The CLI adds three of its own:

| code | Meaning |
|---|---|
| `credentials_in_project` | A credential was found in the project directory. **Clean it up before anything else** |
| `needs_confirmation` | This push would delete things, exceed quota, or is unusually large |
| `network` | Cannot reach the server |
| `engine_outdated` | This template needs a newer renderer than the CLI has. **Run `scripts/install.sh` and try again.** Do not fall back to another template — the user picked that one, and quietly using a different one is how they never find out |
| `template_not_certified` | The version's own samples do not pass its own checks, so it cannot go on the shelf. `pagewell templates validate <id>` names them |

## Order to follow when storage runs out

```
1  pagewell usage --json   → see which of trash / assets / docs is largest
2  Suggest in this order: trash → old versions → orphaned assets
3  Only then mention upgrading
```

⛔ **Never complete a payment for the user.** An upgrade link is fine. Opening
the checkout page, filling a form, or clicking confirm is not. Offer the ways to
free space first — the other order reads as a sales pitch.

## A downgrade never deletes data

`plan_readonly` means "new writes are paused", not "your content is gone".
The three phases are grace → readonly → retained, and **none of them delete
anything**. Say that out loud when you relay the error.
