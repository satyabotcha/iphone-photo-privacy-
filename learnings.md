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
