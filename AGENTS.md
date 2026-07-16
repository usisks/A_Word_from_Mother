# Repository guidance

- Treat `docs/PRODUCT_SPEC.md` as the source of truth. Read it before changing behavior.
- This is an Android-only, local-first Flutter MVP. Do not add iOS, servers, accounts, analytics, ads, networking, SQLite, exact-alarm permissions, or background workers.
- Keep test seams limited to `SettingsStore`, `NotificationGateway`, `Clock`, and `RandomSource`.
- Content in `assets/content/messages.json` is provisional until a human editorial review is recorded. Never describe it as audited merely because validation passes.
- Before handing off, run formatting, analysis, tests, content validation, and Android builds when the required SDKs are available. Report unavailable checks explicitly.
