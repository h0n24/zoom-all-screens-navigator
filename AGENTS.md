# Project instructions

- Write documentation, code comments and Git commit messages in English unless explicitly requested otherwise.
- Keep a single stable application entry point; use Git tags for historical versions.
- Do not close or restart an active Zoom meeting during testing.
- Do not publish meeting content, screenshots, local diagnostics or credentials.
- Every release must include a standalone Windows x64 executable built with the official AutoHotkey Ahk2Exe compiler, so users do not need AutoHotkey installed.
- Publish SHA-256 checksums for all downloadable build artifacts and document how users can verify them. Keep binaries in GitHub release assets, not Git history.
- Smoke-test the compiled application and include runtime licence notices and corresponding AutoHotkey runtime source with binary releases.
- Target Windows only. AutoHotkey and the application's Windows APIs do not run natively on macOS; do not publish or imply a Mac build.
