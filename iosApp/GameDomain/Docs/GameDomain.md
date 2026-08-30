# GameDomain

What more than one feature has to agree about: time controls, ruleset categories, what a game is
played under, and how a clock reads. It imports `Foundation` and depends on no other module.

A type that lives here brings **its own words** with it — the category names sit in this module's
String Catalog, not in the UI. Nothing that imports `SwiftUI` or `UIKit` belongs here — that is
`CoreUI` — and neither does a type only one feature uses: `PresetRuleset` is the setup screen's, and
lives there.

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

The six time controls the app plays under are named on the type itself — `.bullet1plus0`,
`.blitz3plus2`, `.blitz5plus0`, `.rapid10plus0`, `.rapid15plus10`, `.classical90plus30`. The numbers
live here so a screen naming a time control never spells the pair out, and two screens naming the
same one cannot disagree about it.

---

## Ruleset Category

Which family a ruleset belongs to — bullet, blitz, rapid or classical. A `1 | 0` game *is* bullet
wherever it runs, so the classification is domain knowledge and is stated once here.

A category **is named here**, not by whoever draws it — `Bullet`, `Blitz`, `Rapid`, `Classical`, in
natural casing, with each screen uppercasing as its design asks. Both the setup list and the clock
header name the same four categories, and a name defined twice is a name that drifts.

---

## Game Configuration

What a game is played under: a **time control** and the **category** it came from.

The category rides along because the clock screen shows it in the header, and re-deriving it from
the numbers would mean the clock knowing about presets.

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

---

## Copy

The four category names resolve from this module's String Catalog through generated symbols, exactly
as a feature's own copy does.

They sit with the type rather than in `CoreUI` because they are **what a category is called**, not
how a screen draws it: a module handing out `RulesetCategory` while its words lived elsewhere would
give every consumer half a type. `LocalizedStringResource` is Foundation, so owning them costs this
module no UI dependency at all.

**Only copy that names something declared here belongs here.** A ruleset's description is the setup
screen's, because the ruleset is; and sentences that merely mention a category — the setup bar's
`Blitz 3 | 2`, the clock header's `BLITZ · 3 | 2` — belong to the screen that writes them.
