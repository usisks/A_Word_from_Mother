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

### v0.2.0 planned expansion

v0.2.0 is not implemented yet. Its release target is at least 80 messages for each voice and at least 320 messages in total. Continue each existing ID sequence from its current maximum; never reuse a gap.

Automated validation alone does not authorize new copy for publication. Every new or changed v0.2.0 message requires human editorial, safety, language, and dialect review before it can be included in a Release.
