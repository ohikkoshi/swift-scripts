# AGENTS.md

Standalone **macOS** scripts for querying/switching the keyboard Input Method
(`ime-status`, `ime-switch`). No app, no package.

## Run model
- **macOS only.** `ime-status` imports `Carbon` only; `ime-switch` imports
  `Carbon`/`CoreGraphics`/`Foundation` (`TIS*`, `CGEvent`). Apple-only frameworks,
  so neither compiles nor runs on Linux/Windows.
- **No test, no CI, no `Package.swift`.** The `.gitignore` is just the default
  Xcode/SwiftPM/CocoaPods template — none of that exists here, so don't look for
  `swift test`, a package, or a CI workflow. The only tooling is the `swiftc`
  build above and `swift format` below.
- There **is** a build, and it is manual with version-controlled output. The README
  compiles each script to a committed binary:
  `swiftc -O ./src/ime-status.swift -o ./bin/ime-status`
  `swiftc -O ./src/ime-switch.swift   -o ./bin/ime-switch`
  (`bin/ime-*` are committed Mach-O arm64 binaries.)
- Two ways to run — pick the one that matters for the task:
  - Interpreted, always current: `swift src/ime-status.swift`
    (shebang `#!/usr/bin/swift`; `chmod +x` then `./src/ime-status.swift` also works).
  - Compiled artifact: `./bin/ime-status`.
- **Stale-binary gotcha:** nothing rebuilds `bin/` from `src/`. After editing a
  script, re-run the `swiftc -O … -o ./bin/…` build to refresh the committed
  binary, or the two copies silently diverge.

## Lint / format
- The only checker is `swift format` (in the README, configured by the committed
  `.swift-format`: 4-space indent, 120-col lines):
  - Lint, read-only, fails on violations: `swift format lint -r --strict ./src`
  - Format all sources in place: `swift format format -i -r -p ./src`
  - Format one file: `swift format format -i ./src/<name>.swift`
- `-i` rewrites files in place — run `lint` first to check. Needs a Swift 6+
  toolchain that ships the `swift format` subcommand.

## Scripts (`src/`)
Each is an independent entrypoint; there are no shared modules.

- `ime-status.swift` — no args. Prints 3 lines: current input **source ID**,
  **mode ID**, **localized name**. Prints `unknown` and exits `1` if no source is
  available.
- `ime-switch.swift` — requires exactly **2 positional args**:
  `ime-switch.swift <sourceId> <name-or-keycode>`.
  `sourceId` is the TIS `kTISPropertyInputSourceID` (e.g.
  `com.apple.inputmethod.Kotoeri.RomajiTyping.Roman`); see README for an example.
  - Selects the input source by `sourceId` (`TISSelectInputSource`), then
    synthesizes a JIS toggle keypress so the IME actually switches mode.
  - 2nd arg mapping: `Hiragana`/`Kana` → keyCode 104 (JIS Kana);
    `Romaji`/`Roman`/`Eisu` → 102 (JIS Eisu); otherwise parsed as a numeric
    `CGKeyCode`.
  - Exits non-zero (`1`) on usage error, unknown `sourceId`, or a failed
    `TISSelectInputSource` — and these three do print a message to stderr.
  - Two failure paths exit `1` **silently** (no stderr): a non-numeric 2nd arg
    that fails `UInt16` parse, and a `CGEvent` construction failure. Useful as a
    failure signal when scripting, but expect a bare `1` with no message in those cases.

## Gotchas
- These are side-effecting, user-visible actions (they switch the system IME /
  post HID key events) — don't run them in loops or as part of verification.
- Editing a script: keep the `#!/usr/bin/swift` first line and keep each
  file self-contained (no cross-script imports).
