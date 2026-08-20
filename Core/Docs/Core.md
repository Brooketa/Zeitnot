# Core

Zero-dependency foundation module. Holds the app's domain value types, plus non-UI utilities and
extensions shared across features. Nothing here imports SwiftUI or UIKit.

Feature modules cannot import each other, so anything more than one screen needs lives here — and
nothing that doesn't. `TimeControl`, `GameConfiguration` and the time reading are currently the
whole module.

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

Presentation therefore stays out of the domain type. Within a module the format no longer repeats:
since ZN-22 the Setup module keeps it in its own String Catalog under a named key, so its cell and
its Presenter both render the reading without either one writing a `|`.

That does **not** make the format shared across modules. String Catalog symbols are generated per
target, so the catalog has to live in the module that reads it, and the clock screen will need its
own key for the same `3 | 2`. Two modules, two entries, nothing structural keeping them identical —
the original risk, moved rather than removed. Whether they end up sharing one entry somewhere both
can reach is a question for **ZN-60**, along with the rest of the app's copy.

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

## Time Reading

How a time is written for a player to read. One accessor on `Duration`, serving the clock, turns and
statistics screens.

    1:30:00 · 59:59 · 3:07 · 0:08 · 0:00

`h:mm:ss` from an hour up, `m:ss` below it. The leading unit is unpadded, everything after it padded
to two digits. Under a minute it keeps its `0:` — a bare `8` does not read as a time.

**Whole seconds only.** No tenths anywhere. The handoff shows tenths below twenty seconds and the
ticket asked for them under a minute; both were dropped for the first pass. Adding them later
changes this accessor and no screen.

**Truncates towards zero, never rounds.** 1.9 seconds left reads `0:01` — rounding up would show a
player time they do not have, the one direction a clock must not err in. Negatives clamp to `0:00`.

Integer arithmetic on the duration's components, no date formatter and no locale — which is also why
it holds no String Catalog entry.

One accessor rather than a family: with tenths gone, turn durations, totals and the running clock
all want the same string. `Duration` rather than `TimeInterval` because the clock's timing is
monotonic (ZN-25) and produces durations naturally.

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

- Tenths of a second in the time reading — deliberately out of the first pass, see Time Reading
- A String Catalog for the rest of the user-facing copy (ZN-60), and a decision on whether modules
  that render the same string share an entry — see Reading A Time Control. The Setup module carries
  its own catalog already.
- Multi-stage time controls (ZN-53) — deliberately absent; a stage needs a move-number trigger that
  fires per player, which a bare extra duration cannot express

---

## Acceptance Checklist

- [x] A time control expresses a base time and a per-move increment, and zero increment is
      supported.
- [x] A game configuration carries a time control and the category name of the ruleset it came from.
- [x] A game configuration is a value, so a started game is unaffected by later selection changes —
      covered by the Setup module's presenter tests, since that is where a configuration is made.
- [x] One time reading serves the clock, turns and statistics screens.
- [x] The reading switches format at the hour and at the minute, truncates towards zero and clamps
      negatives to `0:00`.
- [x] The reading is locale-independent and holds no user-facing copy.
- [x] Time control and the time reading are covered by unit tests.
