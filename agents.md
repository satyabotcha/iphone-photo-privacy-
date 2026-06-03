# AGENTS.md

## What is this and who is it for?
A free iOS Share Extension for iPhone users who want to show someone selected photos without risking access to private ones. It lives directly in the native Photos share sheet: select photos, tap the extension icon, and hand the phone over. The recipient can see only the chosen photos, with nothing else accessible.

## Magic Moment
The user is already in Photos, already looking at the photo they want to share. They tap Share, tap the extension icon, and hand over the phone in the same motion they were already making. There is no setup, no app switching, no explanation, and no awkward pause. The recipient sees exactly what was intended. The user feels nothing because the anxiety has disappeared.

## Product Philosophy
This is not a photo vault, locker, or privacy bunker. It is not a separate app people need to remember to open. It is not feature-heavy, configurable, or educational. It should feel native, invisible, and obvious: a tiny extension that removes one specific anxiety at the exact moment it appears.

---

## Tech Stack
- **Language:** Swift 5.9
- **UI:** SwiftUI with small UIKit bridges where needed
- **Platform:** iOS 17+
- **Project generation:** XcodeGen via `app/project.yml`

## Map
- `app/LockedPhotos`: containing iOS app and shared viewer UI
- `app/LockedPhotosShareExtension`: share/action extension host code and selected-photo loader
- `app/LockedPhotosActionExtension`: Action Extension plist; reuses the share extension host code
- `app/LockedPhotosUITests`: UI tests for the demo Don't Swipe flow
- `app/project.yml`: source of truth for the Xcode project; run `xcodegen generate` after target changes

---

## Current Product/Technical Decisions
- Public user-facing name is "Don't Swipe"; keep internal target/module paths as `LockedPhotos` unless doing an explicit migration.
- Ship both entry points while testing user flow:
  - Share Extension: `com.apple.share-services`, appears in the app/share destination area.
  - Action Extension: `com.apple.ui-services`, appears in the action list and requests full-screen presentation.
- Both extensions currently display as "Don't Swipe" and reuse the same loader/viewer code.
- The Don't Swipe viewer should feel close to Photos: black full-screen viewer, swipe/zoom, top controls, and a bottom thumbnail filmstrip. Tap the photo to hide all chrome/status bar for native full-screen viewing; tap again to bring controls back.
- Selected photos preserve basic embedded metadata when available: capture date and GPS coordinates are shown with the visible chrome and disappear when chrome is hidden.
- The app onboarding storyboard must teach the exact first-run share sheet setup path slowly: Photos Share -> More -> Edit -> plus next to Don't Swipe -> confirm Favorites -> Done -> tap Don't Swipe.
- iOS does not expose whether the extension is in Share Sheet Favorites. Use `ShareSetupState` in App Group `group.com.satyabotcha.LockedPhotos` as the proxy: once either extension launches, mark setup complete and stop showing onboarding in the container app.

## Instructions

**Before starting:** Read `soul.md` and `learnings.md` before every task.

**During:**
- Ask one clarifying question if the task is ambiguous — don't just start building
- Blast radius: 1-2 files → proceed. 3-5 files → inform me + add tests for affected functions. 5+ files → stop, confirm with me, add full tests, and do NOT commit until I approve
- Add comments on non-obvious logic — explain *why*, not *what*

**After:**
- Commit only files you edited: `[type]: short description`, then push to GitHub
- Maintain 90% test coverage — every feature and fix ships with tests
- Update `learnings.md` if you hit a bug or a failed approach
- Update this file aggressively — any pattern, constraint, or decision that would help a future agent understand this project faster belongs here. When in doubt, add it.

---

*Living document. Keep it lean — add only what can't be figured out from reading the code.*
