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

Run `dart run tool/validate_content.dart` after every edit. Passing validation is not an editorial audit. Before publication, a human reviewer must review every message in context and record approval outside the JSON.

## Current status

The initial 160 messages are provisional implementation content (40 per voice). They have automated structural checks only and must not ship publicly before human editorial review.
