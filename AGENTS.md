# Repository guidance

- Treat `docs/PRODUCT_SPEC.md` as the source of truth. Read it before changing behavior.
- For v0.2.0 implementation, also read `docs/V0.2.0_DETAILED_DESIGN.md`. Implement, test, and review the diff one phase at a time.
- This is an Android-only, local-first Flutter MVP. Do not add iOS, servers, accounts, analytics, ads, networking, SQLite, exact-alarm permissions, or background workers.
- Keep test seams limited to `SettingsStore`, `NotificationGateway`, `Clock`, and `RandomSource`.
- Keep separate `RandomSource` instances for notification scheduling and the in-app message; they must not share one instance.
- Do not add external dependencies unless there is a documented, necessary exception.
- The 160 v0.1.0 messages have a recorded human editorial and safety audit. New or changed copy is not audited merely because automated validation passes; do not include unaudited copy in a Release.
- When requirements change, update both `docs/PRODUCT_SPEC.md` and `docs/V0.2.0_DETAILED_DESIGN.md`. Add a reproduction test with every bug fix.
- Before handing off, run formatting, analysis, tests, content validation, and Android builds when the required SDKs are available. Report unavailable checks explicitly.
