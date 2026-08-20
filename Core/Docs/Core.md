# Core

Zero-dependency foundation module. Holds the app's domain value types, plus non-UI utilities and
extensions shared across features. Nothing here imports SwiftUI or UIKit.

Feature modules cannot import each other, so anything more than one screen needs lives here — and
nothing that doesn't. `TimeControl` and `GameConfiguration` are currently the whole module.

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
ruleset cells, under the START GAME button and in the clock's navigation title is built by the
screen that shows it, from those two values.

This keeps presentation out of the domain type. The trade-off accepted with it: the same
`"\(baseMinutes) | \(incrementSeconds)"` format is written in Setup and Clock, which are separate
modules that cannot import one another, so nothing structurally prevents the two from drifting
apart. The planned resolution is a single String Catalog entry taking both numbers as arguments
(**ZN-60**), which single-sources the format without putting a computed property back on the model.

---

## Game Configuration

What the setup screen hands to the clock when a game starts: the `TimeControl` the game is played
under, plus the **category name** of the ruleset it came from (`"Classical"`).

It carries the category because the clock's navigation title reads `● CLASSICAL · 90 | 30`, and the
clock has to get that word from somewhere. It carries the category *name* rather than a rendered
title so the clock composes its own chrome — the bullet, the middot and the casing are the clock's
presentation, and Setup has no business knowing about them. This settles the open question this
document carried until ZN-22.

It is a value type, and that is load-bearing rather than incidental. The configuration is read at
the moment START GAME is tapped, so a game under way holds a snapshot: changing the selection on the
setup screen afterwards cannot reach into it. The rule "changing the selection later does not alter
a game already under way" is therefore structural, not something the clock has to remember to
honour.

Nothing else about a ruleset crosses this boundary. The description, the storage key and the
selection state are all setup-screen concerns and stop there.

The type exists ahead of its consumer: the setup screen builds a configuration when START GAME is
tapped, but the clock screen that receives one is ZN-23. It lives here rather than in Setup because
the boundary it describes is between two feature modules, which cannot import one another.

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
It isn't. The clock needs a time control to run a game and a *word* to put in its title bar, which
is exactly what `GameConfiguration` carries — never a category type, and never the ruleset itself.

Moved out of Core on 2026-08-19, during ZN-15.

---

## Not Built Yet

- Duration formatting for the clock, turns and statistics screens (ZN-23 onwards)
- A String Catalog for user-facing copy, including the `3 | 2` notation key (ZN-60)
- Multi-stage time controls (ZN-53) — deliberately absent; a stage needs a move-number trigger that
  fires per player, which a bare extra duration cannot express

---

## Acceptance Checklist

- [x] A time control expresses a base time and a per-move increment, and zero increment is
      supported.
- [x] A game configuration carries a time control and the category name of the ruleset it came from.
- [x] A game configuration is a value, so a started game is unaffected by later selection changes —
      covered by the Setup module's presenter tests, since that is where a configuration is made.
- [x] Time control is covered by unit tests.
