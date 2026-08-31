# Repository Guidelines

## Project Structure & Module Organization

- `Sources/SoundViz/` contains the macOS executable and core modules for audio capture, FFT analysis, visualization rendering, and menu bar integration.
- `Tests/SoundVizTests/` contains XCTest coverage for shared logic and analyzer behavior.
- `Resources/` stores the app icon source and generated `.icns` asset.
- `docs/images/` contains README screenshots; `docs/adr/` is reserved for architecture decisions.
- `scripts/` contains asset-generation and local verification helpers.
- `.github/workflows/` runs macOS CI for tests, packaging, and bundle validation.

## Build, Test, and Development Commands

- `swift test`: build in debug mode and run all XCTest cases.
- `make build` or `./build-app.sh`: build the release binary and package `build/SoundViz.app`.
- `make run`: package the app and launch it locally.
- `make icon`: regenerate `Resources/AppIcon.png` and `Resources/SoundViz.icns`.
- `make verify`: run tests, package the app, lint `Info.plist`, and verify ad-hoc signing.
- `make clean`: remove SwiftPM and app bundle artifacts.

## Coding Style & Naming Conventions

Use Swift 5.9 conventions with four-space indentation, as defined in `.editorconfig`. Name types with `PascalCase`, members and functions with `camelCase`, and constants with `camelCase` unless a scoped static value reads better in uppercase. Keep types in files matching their primary type, such as `SpectrumAnalyzer.swift`.

Keep AppKit rendering and status item mutations on the main thread. In real-time audio callbacks, avoid locks, UI work, logging, and avoidable allocations. Do not introduce system volume as a visualization parameter.

## Testing Guidelines

Add XCTest coverage in `Tests/SoundVizTests/` for analyzer behavior, normalization, spectrum shape, and user-facing configuration logic. Name tests by behavior, for example `testSpectrumAnalyzerProducesStableFrameShape`. Run `swift test` before committing. Changes to DSP, rendering state, packaging, or permissions should include a focused test or a documented manual verification step.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commit-style subjects such as `feat:`, `fix:`, and `docs:`. Keep subjects short, imperative, and specific.

Pull requests should include a concise summary, the motivation, testing performed, and screenshots for menu bar visual changes. Link related GitHub issues when applicable. Ensure CI passes and include before/after captures when visualization output changes.

## Security & Configuration Tips

Do not commit secrets, signing identities, recordings, or local build outputs. Audio is processed in memory only; preserve that behavior. The app requires macOS audio capture permission and deliberately avoids Screen Recording permission. Use `CODESIGN_IDENTITY` only as an environment variable when packaging with a Developer ID certificate.

## Agent skills

### Issue tracker

Issues and specs are tracked as local Markdown files under `.scratch/`; GitHub is used only for repository synchronization. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five canonical triage labels without renaming. See `docs/agents/triage-labels.md`.

### Domain docs

Use the single-context layout with `CONTEXT.md` and `docs/adr/`. See `docs/agents/domain.md`.
