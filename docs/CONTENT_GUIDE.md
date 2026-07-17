# Content guide

`assets/content/messages.json` contains bundled notification copy. The runtime never creates or downloads copy.

## Requirements

- Keep every ID permanent and unique: `language-voice-category-0000`.
- Keep bodies between 1 and 90 characters and unique across the file.
- Keep Japanese copy in `standard` or `kansai`; English copy in `neutral` or `british`.
- Do not refer to real people, companies, shops, organizations, or bodies.
- Do not include dangerous medical, food-safety, disaster, legal, financial, discriminatory, sexual, violent, coercive, or privacy-invasive claims.
- `fake_tip` must read as harmless absurdity. It is still accompanied by the in-app fictional-tip warning.
- Avoid exaggerated dialect stereotypes.

Run `dart run tool/validate_content.dart` after every edit. Passing validation is not an editorial audit. Before publication, a human reviewer must review every new or changed message in context and record approval outside the JSON.

## Current status

### v0.1.0 released content

The 160 v0.1.0 messages (40 per voice) completed human editorial and safety review in addition to automated validation. Their IDs are permanent: do not rename them or reuse any missing ID.

### v0.2.0 reviewed expansion

v0.2.0 adds 160 messages, bringing the bundle to 80 messages per voice and 320 messages in total. The original 160 v0.1.0 entries and their IDs remain unchanged. New IDs continue each voice sequence from `0041` through `0080`; never rename an ID or reuse a gap.

Reviewer やまと approved all 160 v0.2.0 additions on 2026-07-17 after editorial, safety, language or dialect, and duplication or similarity review. The result is recorded in [`V0.2.0_CONTENT_AUDIT.md`](V0.2.0_CONTENT_AUDIT.md). Automated validation remains mandatory after any content change, and future additions or edits require another human review.
