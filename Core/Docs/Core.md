# Core

Zero-dependency foundation module. Holds the app's domain value types, plus non-UI utilities and
extensions shared across features. Nothing here imports SwiftUI or UIKit.

Feature modules cannot import each other, so anything more than one screen needs lives here — and
nothing that doesn't. `TimeControl` is currently the whole module.

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

Core exposes the two values and deliberately does not render them. The `3 | 2` reading shown on the
ruleset cells, under the START GAME button and in the clock's navigation title is built by each
screen's Presenter from those two values.

This keeps presentation out of the domain type. The trade-off accepted with it: the same
`"\(baseMinutes) | \(incrementSeconds)"` format is written in Setup and Clock, which are separate
modules that cannot import one another, so nothing structurally prevents the two from drifting
apart. The planned resolution is a single String Catalog entry taking both numbers as arguments
(**ZN-60**), which single-sources the format without putting a computed property back on the model.

---

## What Deliberately Is Not Here

The preset catalogue lives in the **Setup** module. There is no `Ruleset` type and no category type
anywhere — a preset carries its category name, time control and description directly. A struct
wrapping two of those, and an enum whose only job was to return a label, both earned nothing.

A time control is what a game is genuinely played under — the clock counts it down, reset restores
it, rematch reuses it. Everything else about a ruleset is presentation belonging to the screen that
presents it: the category name, the description under each option, whether it is the editable custom
one.

The clock screen does display `● CLASSICAL · 90 | 30`, which looks like a reason to share the types.
It isn't. The clock needs a time control to run a game and a *string* to put in its title bar. When
ZN-22 wires START GAME to the clock, the hand-off carries a `TimeControl` plus display text, so the
clock never needs to know what a category is.

Moved out of Core on 2026-08-19, during ZN-15.

---

## Not Built Yet

- The Setup → Clock hand-off model (ZN-22). It belongs here, since feature modules cannot import one
  another. Open question: whether it carries a fully-rendered title or the category name plus the
  time control, with the clock composing its own `● … · …` chrome.
- Duration formatting for the clock, turns and statistics screens (ZN-23 onwards)
- A String Catalog for user-facing copy, including the `3 | 2` notation key (ZN-60)
- Multi-stage time controls (ZN-53) — deliberately absent; a stage needs a move-number trigger that
  fires per player, which a bare extra duration cannot express

---

## Acceptance Checklist

- [x] A time control expresses a base time and a per-move increment, and zero increment is
      supported.
- [x] Covered by unit tests.
