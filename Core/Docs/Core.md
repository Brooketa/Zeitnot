# Core

Zero-dependency foundation module. Holds the app's domain value types, plus non-UI utilities and
extensions shared across features. Nothing here imports SwiftUI or UIKit.

Feature modules cannot import each other, so anything more than one screen needs lives here.

---

## Time Control

A time control is what a game is played under: **one clock budget per player for the whole game,
plus time credited to a player each time they complete a move.**

- `baseMinutes` — the player's entire budget for the game. It counts down only while it is that
  player's turn. There is **no per-turn limit**: a player may spend the whole budget on a single
  move, and then they have nothing left.
- `incrementSeconds` — credited to the player **who just completed a move**, not the one about to
  move. Zero is valid and means no time is ever added.

Both are `Int`, in the units time controls are written in and the units the custom steppers produce.
A time control is configuration, not elapsed time: every value it can hold is a whole number of
minutes or seconds, so it needs no sub-second precision. The clock's *running* state is a different
matter — that needs monotonic timing and tenths in the last ten seconds, and belongs to ZN-23.

Storing plain integers also keeps the persisted form legible for ZN-20: `{"baseMinutes":3,
"incrementSeconds":2}` rather than an opaque attosecond pair.

### Reading a time control

Core exposes the two values and deliberately does not render them. The `3 | 2` reading shown on the ruleset cells, under the START GAME button and in the
clock's navigation title is built by each screen's Presenter from those two values.

This is a deliberate decision to keep presentation out of the domain type. The trade-off accepted
with it: the same `"\(baseMinutes) | \(incrementSeconds)"` format is written in Setup and Clock,
which are separate modules that cannot import one another, so nothing structurally prevents the two
from drifting apart. The planned resolution is a single String Catalog entry
taking both numbers as arguments (**ZN-60**), which single-sources the format without putting a
computed property back on the model.

## Ruleset

A category paired with the time control it is played under. This is what the clock screen's
navigation title reads from (`● CLASSICAL · 90 | 30`) and what a started game is configured from.

`isCustom` derives from the category rather than being stored separately, so the two cannot
disagree.

A ruleset deliberately carries **no description**. The short line under each option on the setup
screen is catalogue copy that appears on that screen and nowhere else — not on the clock, and not on
Statistics — so it belongs with the presets (ZN-15) rather than in the shared module.

## Ruleset Category

`Bullet`, `Blitz`, `Rapid`, `Classical`, `Custom`. Each supplies the `title` shown at the top of a
ruleset cell.

Titles are **natural-cased** (`"Bullet"`). The uppercase treatment on the cells is presentation and
is applied by the view.

---

## Not Built Yet

- The six preset rulesets and their copy (ZN-15)
- How a selection is identified and persisted (ZN-17, ZN-20)
- Duration formatting for the clock, turns and statistics screens (ZN-23 onwards)
- A String Catalog for user-facing copy, including `RulesetCategory.title` and the `3 | 2` notation
  key (ZN-60)
- Multi-stage time controls (ZN-53) — deliberately absent; a stage needs a move-number trigger that
  fires per player, which a bare extra duration cannot express

---

## Acceptance Checklist

- [x] A time control expresses a match time and a per-move increment, and zero increment is
      supported.
- [x] A ruleset carries its category and time control, and custom is distinguishable from a preset.
      Description was removed as setup-only catalogue copy (see ZN-14 note, 2026-08-19).
- [x] Every category has the title used on the cells.
- [ ] A time control renders as `3 | 2`, and `1 | 0` when there is no increment — **not Core's
      job**; each Presenter formats it from `baseMinutes` / `incrementSeconds`. Verified where those
      Presenters are built (ZN-21 onwards).
- [x] Covered by unit tests.
