# Core

The lowest module. Non-UI types and extensions shared by more than one feature. It imports nothing
and depends on nothing.

Nothing that imports `SwiftUI` or `UIKit` belongs here — that is `CoreUI`. Nor does anything only one
feature uses.

---

## Time Control

A time control is **base minutes plus an increment in seconds**. That is the whole model.

```swift
TimeControl(baseMinutes: 3, incrementSeconds: 2)
```

It stores integers because that is what the player picks and what the copy reads back, and exposes
`baseTime` and `increment` as `Duration` for the clock to do arithmetic with. Storing durations
instead would mean converting back to integers every time a label is drawn.

It is `Hashable`, `Codable` and `Sendable` — a value with no identity and no behaviour.

---

## Game Configuration

What a game is played under: a **time control** and the **category name** it came from (`"Classical"`).

The category rides along because the clock screen shows it in the header, and re-deriving it from
the numbers would mean the clock knowing about presets. It is resolved text, not a resource, so the
domain never carries a localization key.

It is a value taken when a game starts, which is what stops a later selection change reaching a game
already under way.

---

## Time Reading

One shared way to render a duration, as an accessor on `Duration`:

| Remaining | Reads |
|---|---|
| 1h 30m | `1:30:00` |
| 59m 59s | `59:59` |
| 3m 7s | `3:07` |
| 8s | `0:08` |
| 0 | `0:00` |

- `h:mm:ss` from an hour up, `m:ss` below it.
- **Whole seconds only.** No tenths anywhere.
- **Truncates towards zero, never rounds.** 1.9 seconds left reads `0:01` — showing a player time
  they do not have is the one direction a clock must not err in.
- Never negative; a clock at or past zero reads `0:00`.

It lives here rather than in the clock so that any screen showing a time reads the same one, and the
format cannot diverge between two callers.
