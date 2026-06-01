# learnings.md

*Updated by the agent after every meaningful task. Check this before starting any task.*
*If this exceeds 5kb, summarise older entries and delete them — keep it lean.*

---

## Format

```
### [YYYY-MM-DD] What happened
**Context:** What we were trying to do
**Learning:** What went wrong or what we discovered
```

---

## Entries

### [2026-05-24] Explicit simulator destinations
**Context:** Building and testing the iOS app after adding a second extension target.
**Learning:** `xcodebuild` failed when using `platform=iOS Simulator,name=iPhone 15` because the machine did not resolve a matching "latest" OS, even though an iPhone 15 simulator existed. Use the explicit simulator id `D471F4D5-0CC3-4298-ABE7-3231BE6C00E8` or include the installed OS (`17.5`) for reliable local builds.

### [2026-05-24] Physical device build preflight
**Context:** Preflighting a build for the connected "Satya's iphone" after simulator verification passed.
**Learning:** `xcodebuild` saw the paired iPhone 16 but timed out because the developer disk image could not be mounted. Resolve the device/Xcode pairing state before relying on CLI device builds; simulator builds and tests still work.

### [2026-05-26] SwiftUI overlay accessibility
**Context:** Verifying Photos-like metadata chrome in the handoff viewer with UI tests.
**Learning:** A combined accessibility identifier on a container did not surface reliably for SwiftUI overlay text. Put identifiers on the visible `Text` elements and assert their disappearance when the chrome is hidden.

### [2026-06-01] Photos-like handoff chrome
**Context:** Making the handoff viewer feel closer to the native Photos app.
**Learning:** Keep the viewer chrome state light and system-backed, then switch the canvas to black only when chrome is hidden. Action extensions can request full-screen presentation in the plist; Share extension hosts may still constrain the outer sheet, so the Action extension remains the cleanest Photos-like handoff path.

### [2026-06-01] EXIF wall-clock display
**Context:** Matching the native Photos timestamp in the handoff viewer.
**Learning:** `DateTimeOriginal` EXIF values are camera wall-clock timestamps, not timezone-shiftable instants. Parse and display them in a fixed display timezone so a photo captured at 9:55 pm does not render as 10:55 pm on a device currently using daylight-saving time.

### [2026-06-01] Simulator biometric command availability
**Context:** Verifying Face ID-gated exit from the handoff viewer on the iPhone 17 simulator.
**Learning:** This local Xcode `simctl` does not expose the older `biometric` subcommand, so automated Face ID match/fail simulation from shell is unavailable. Use UI tests for fail-closed behavior and verify successful authentication on a physical device or through Simulator UI features when available.
