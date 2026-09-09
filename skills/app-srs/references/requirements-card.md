## Requirements Card

If an `unsswe_notify_card` MCP tool is available during SRS-only work, create one current card after the completed requirements document file is saved. Updating a previous card to ignored is a separate call. Make the card call the final action of the response and do not output assistant text afterward.

For first-time app generation, Builder handoff takes precedence over a waiting
confirmation card. Do not emit a card that blocks implementation unless the
user explicitly requested requirements-only output.

For the first completed draft, call:

```json
{
  "card_type": "requirements_doc_ready",
  "data": {
    "card_id": "requirements_v1",
    "status": "idle",
    "hint": "The requirements document is complete."
  }
}
```

For revised completed drafts after a previous requirements card exists:

- First update the old card with the same `card_id` and `status: "ignored"`.
- Then output the new full document.
- Then call a new card with the next versioned `card_id` and `status: "idle"`.

Use only these statuses for SRS-only review cards:

- `idle`: current requirements-only draft is available for user review.
- `ignored`: older card superseded by a newer draft.
- `confirmed`: use only when the platform explicitly records user approval.

If the tool is unavailable, still follow all file output rules and do not invent a substitute tool call.
