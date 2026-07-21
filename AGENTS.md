# SoyBean Package Specification and Contributor Guide

`AGENTS.md` and `CLAUDE.md` must remain byte-for-byte identical. Whenever one file changes, apply the same change to the other file in the same commit.

## Project Overview

SoyBean is a dependency-free Swift Package that collects reusable extensions, logging, formatting, validation, security utilities, SwiftUI components, and platform UI helpers.

- Swift tools version: 5.10
- Minimum platforms: iOS 15, macOS 12, watchOS 8
- Package products: `SoyBean`, `SoyBeanCore`, `SoyBeanUI`, `SoyBeanUtil`
- External package dependencies: none
- Primary manifest: `Package.swift`
- Tests: `Tests/SoyBeanTests`

The aggregate `SoyBean` product re-exports all three submodules. Consumers that need a smaller dependency surface may import a submodule directly.

## Module Architecture

```text
SoyBean
├── SoyBeanCore
├── SoyBeanUI ──> SoyBeanCore
└── SoyBeanUtil ─> SoyBeanCore
```

### SoyBean

`Sources/SoyBean` is the aggregate entry point. `Importer.swift` re-exports `SoyBeanCore`, `SoyBeanUI`, and `SoyBeanUtil` with `@_exported import`.

### SoyBeanCore

`Sources/SoyBeanCore` contains code that should be broadly reusable:

- `SoyBeanError`
- `Log` wrappers around OSLog
- Foundation and Swift standard-library extensions
- Combine helpers and cancellable storage
- iOS-only keyboard publishers, guarded with `#if os(iOS)`

Keep this target independent of `SoyBeanUI` and `SoyBeanUtil`.

### SoyBeanUI

`Sources/SoyBeanUI` contains:

- SwiftUI views, modifiers, colors, fonts, and effects
- Bundled OTF font resources
- UIKit extensions and haptic support on iOS
- AppKit font support on macOS
- `ToastView` implementations for both UIKit and AppKit

UI code must be conditionally compiled when its framework is unavailable. Prefer shared SwiftUI implementations when behavior and API remain appropriate across platforms.

### SoyBeanUtil

`Sources/SoyBeanUtil` contains:

- Date formatting and regular-expression validation
- JWT and Base64URL decoding helpers
- Codable Keychain storage backed by Security
- UserDefaults migration support
- iOS application helpers
- macOS clipboard access

## Platform Support

The package declares iOS 15+, macOS 12+, and watchOS 8+. A declared platform does not make every API available on that platform.

| Capability | iOS | macOS | watchOS |
| --- | --- | --- | --- |
| Core Foundation/Swift extensions | Yes | Yes | Yes |
| Logging and general utilities | Yes | Yes | Yes, where the underlying Apple framework is available |
| Shared SwiftUI components | Yes | Yes | Yes, subject to API availability checks |
| Keyboard publishers | Yes | No | No |
| UIKit extensions and haptics | Yes | No | No |
| AppKit-specific helpers | No | Yes | No |
| Toast presentation | UIKit | AppKit | No |

Use `#if os(iOS)`, `#elseif os(macOS)`, and availability checks to preserve these boundaries. Do not introduce an unconditional UIKit or AppKit import into a shared target.

## Toast API Contract

`ToastDuration` supports `.short` (3 seconds) and `.long` (6 seconds). `ToastType` supports `.positive` and `.negative`.

The `sbShowToast(message:duration:isShowTop:type:)` API is available from:

- iOS: `UIView`, `UIViewController`, and SwiftUI `View`
- macOS: `NSView`, `NSViewController`, and SwiftUI `View`

Both implementations support centered or top presentation, automatic dismissal, and a shake animation for negative feedback. iOS additionally emits haptic feedback. macOS intentionally does not emulate haptics.

## Resources

Font files live in `Sources/SoyBeanUI/Resources` and are processed by the `SoyBeanUI` target. Access package resources through `Bundle.module`. Register fonts before using the package font helpers:

```swift
Font.registerFonts()
```

Do not move or rename a font without updating `FontType` and verifying resource loading.

## Development Rules

- Treat `Package.swift` and `Sources` as the source of truth.
- Preserve the existing module dependency direction. Do not make Core depend on UI or Util.
- Keep public API access levels explicit and add concise documentation comments for new public declarations.
- Prefer Foundation or Swift standard-library types in shared code.
- Place platform-specific code behind compile-time guards that cover the import and every dependent declaration.
- Preserve existing public behavior unless a breaking change is explicitly requested.
- Do not add third-party dependencies for functionality available in Apple frameworks or the standard library without a clear requirement.
- Do not manually edit generated content under `Derived` or generated Xcode project data unless the task specifically requires it.
- Keep the Korean `README.md` aligned with platform support, products, public usage, and module structure described here.

## Verification

Run macOS package verification with:

```sh
swift build
swift test
```

When platform code changes, also compile the relevant Apple target. An iOS library build can be checked with SwiftPM using the installed iPhoneOS SDK and an `arm64-apple-ios15.0` triple, or with an appropriate Xcode scheme.

Before completing a change:

1. Run `git diff --check`.
2. Build every affected platform.
3. Run tests when the test target compiles.
4. Confirm that `AGENTS.md` and `CLAUDE.md` are identical.
5. Update `README.md` when user-visible behavior, supported platforms, installation, products, or examples change.
