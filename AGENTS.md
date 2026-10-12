# GM MINI BAR — Legion / SPP

- Target WoW 7.3.5 build 26972, Interface 70300, Lua 5.1 and SPP Legion V2 Praevius 2026.2a.
- Read README.md, release.json, GMminibar/SOURCES.md and GMminibar/GAME_TEST.md first.
- Preserve the one-folder installation, saved settings and established GM MINI BAR layout.
- Keep Legion APIs, commands and data separate from other client editions.
- Use secure hardware actions for protected target and inventory operations. Do not call protected functions from insecure callbacks.
- Match imported DB2 data to the documented client layout and retain provenance and license notices.
- Run python scripts/validate.py and python scripts/package.py after changes, including documentation changes.
- Keep addon-manifest.json in sync with deliberate addon changes. Do not silently rewrite the manifest during validation.
- Mocked checks and command help availability are not evidence of successful gameplay. Record game tests and limits separately.
- Do not publish accounts, credentials, server configuration, SavedVariables, full SQL databases, client archives or server/client binaries.
- Publish or replace releases only within the user's authorized scope. Preserve exact tested release assets.
