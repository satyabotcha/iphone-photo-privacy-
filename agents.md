# AGENTS.md

## Onboarding
*If the sections below marked [FILL IN] are still empty, do not proceed with any task. Instead, ask the user the following questions one at a time and wait for their answers:*

1. *What is this project? Who is it for, what problem does it solve, and why does it matter to them? Take as much space as you need — the more context, the better.*
2. *What does the magic moment look like? Describe the ideal user experience — the exact moment the user gets value and feels something.*

*Once both answers are received: restate the proposed answer for each section, infer the product philosophy from what the user described — what this product clearly is NOT based on their answers — and ask the user to confirm. Only after the user confirms: fill in both sections yourself, add the product philosophy, and remove this Onboarding section. This onboarding runs once only.*

## What is this and who is it for?
[FILL IN — see Onboarding above]

## Magic Moment
[FILL IN — see Onboarding above]

---

## Tech Stack
- **Language:** [e.g. TypeScript]
- **Frontend:** [e.g. React, Next.js]
- **Backend:** [e.g. Node, Vercel]
- **Database:** [e.g. Postgres, Supabase]
- **Styling:** [e.g. Tailwind CSS]

## Map
*On first run: scan the repo and write a one-line description per top-level folder. Update when structure changes. Telegraph style.*

---

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
