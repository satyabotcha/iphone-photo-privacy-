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
**Context:** Verifying Photos-like metadata chrome in the Don't Swipe viewer with UI tests.
**Learning:** A combined accessibility identifier on a container did not surface reliably for SwiftUI overlay text. Put identifiers on the visible `Text` elements and assert their disappearance when the chrome is hidden.

### [2026-06-01] Photos-like Don't Swipe chrome
**Context:** Making the Don't Swipe viewer feel closer to the native Photos app.
**Learning:** Keep the viewer chrome state light and system-backed, then switch the canvas to black only when chrome is hidden. Action extensions can request full-screen presentation in the plist; Share extension hosts may still constrain the outer sheet, so the Action extension remains the cleanest Photos-like Don't Swipe path.

### [2026-06-01] EXIF wall-clock display
**Context:** Matching the native Photos timestamp in the Don't Swipe viewer.
**Learning:** `DateTimeOriginal` EXIF values are camera wall-clock timestamps, not timezone-shiftable instants. Parse and display them in a fixed display timezone so a photo captured at 9:55 pm does not render as 10:55 pm on a device currently using daylight-saving time.

### [2026-06-01] Simulator biometric command availability
**Context:** Verifying Face ID-gated exit from the Don't Swipe viewer on the iPhone 17 simulator.
**Learning:** This local Xcode `simctl` does not expose the older `biometric` subcommand, so automated Face ID match/fail simulation from shell is unavailable. Use UI tests for fail-closed behavior and verify successful authentication on a physical device or through Simulator UI features when available.

### [2026-06-01] Removed controls need real absence tests
**Context:** Removing the inert options control from the Don't Swipe viewer.
**Learning:** Do not replace removed SwiftUI controls with hidden accessibility shims just to keep UI tests stable. Assert the removed element no longer exists, and use visible surviving chrome for behavior coverage.

### [2026-06-01] Onboarding visuals need real app imagery
**Context:** Building the first-run Don't Swipe setup animation.
**Learning:** Placeholder color tiles make the Photos walkthrough feel fake. Bundle a small reusable demo photo set and use those same images in onboarding, UI-test demo mode, and the locked viewer.

### [2026-06-01] Simulator test launch prep can flake
**Context:** Running UI tests after changing the Don't Swipe onboarding storyboard.
**Learning:** `xcodebuild test` can fail before assertions with `Invalid connectionUUID specified` while preparing the simulator. Boot the explicit simulator with `xcrun simctl bootstatus <device-id> -b` and rerun before treating it as a product failure.

### [2026-06-03] Share Sheet Favorites cannot be observed directly
**Context:** Hiding Don't Swipe onboarding after setup.
**Learning:** iOS has no public API for reading whether an extension was added to Share Sheet Favorites. Use a shared App Group flag set when the Share/Action Extension launches, then have the container app treat that as setup complete.

### [2026-06-03] Onboarding selection count must match visible checkmarks
**Context:** Fixing the setup animation after it showed "3 Selected" while only one selected photo was visible.
**Learning:** Keep all onboarding-selected thumbnails inside the visible clipped Photos grid; avoid selecting lower-row items unless the animation also scrolls or reveals them.

### [2026-06-03] Onboarding selections need a visible zero-to-three beat
**Context:** Making the Photos setup animation feel more natural before the Share Sheet appears.
**Learning:** Start the Photos mock at zero selected, animate each checkmark in one at a time, and advance directly from the third selected photo into the share sheet.

### [2026-06-03] Onboarding copy should be editable and CTA-backed
**Context:** Reworking setup instructions to feel closer to Raycast's onboarding card.
**Learning:** Keep setup instruction text in one editable array, render it as a numbered list, include a clear bottom CTA for the first external action, and keep the copy short enough for first-time users without restating self-evident follow-up steps.

### [2026-06-03] Onboarding should keep animation as the hero
**Context:** Fitting setup instructions and the Open Photos button on one screen.
**Learning:** Let the animation take the visual priority, scale it responsively, and keep instruction typography compact enough that the CTA remains visible without scrolling.

### [2026-06-03] Thumbnail selection badges need stable layout
**Context:** Making selected ticks reliably appear in the onboarding Photos grid.
**Learning:** Put selection badges inside an explicit thumbnail `ZStack` after the image is sized, and keep the onboarding Photos grid to the visible selected row so bottom badges cannot fall into clipped hidden rows.

### [2026-06-03] Completed setup still needs a recovery path
**Context:** Hiding onboarding after the Share/Action Extension has launched once.
**Learning:** Do not put first-run onboarding back in the main path after setup is complete, but keep a small top-level setup guide button so users can recover the share-sheet instructions later.

### [2026-06-03] Selection animation should stay literal
**Context:** Simplifying the onboarding photo-selection beat.
**Learning:** For selected photos, the bottom-right checkmark appearing is enough. Extra tap/pulse motion makes the animation feel less native and distracts from the selected state.
