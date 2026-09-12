# Shared

Everything both platforms agree about: what a game is played under, the rules the clock enforces, and
the presenters that turn that state into what a screen shows. It imports `Observation` and nothing
else, and depends on no other module.

**Shared holds identity and classification; the platform holds the words.** A category, a side, a
state and a time reading mean the same thing on iOS and Android, so they live here. Their names —
`Bullet`, `WHITE`, `FLAG FELL` — are copy, and copy belongs to whichever app is drawing it.

That line is not a preference. `LocalizedStringResource` does not exist outside Apple's platforms, so
a shared type carrying copy would not compile for Android at all.

---

## Time Control

A time control is **base minutes plus an increment in seconds**. That is the whole model.

```swift
TimeControl(baseMinutes: 3, incrementSeconds: 2)
```

It stores integers because that is what the player picks and what the copy reads back, and exposes
`baseTime` and `increment` as `Duration` for the clock to do arithmetic with.

The six time controls the app plays under are named on the type — `.bullet1plus0`, `.blitz3plus2`,
`.blitz5plus0`, `.rapid10plus0`, `.rapid15plus10`, `.classical90plus30` — so two screens naming the
same one cannot disagree about it.

---

## Ruleset Category

Which family a ruleset belongs to: bullet, blitz, rapid or classical. A `1 | 0` game *is* bullet
wherever it runs, so the classification is domain knowledge and is stated once here.

The category is a **token and nothing more**. It carries no name. Each app names the four categories
in its own String Catalog and uppercases as its design asks.

---

## Preset Rulesets

The six presets the setup screen offers, in display order, each pairing a time control with its
category. Every preset has a **stable string id** — `bullet-1-0`, `blitz-3-2` and so on — which is the
identity a view round-trips when a player picks one. The ids are keys rather than derived from the
numbers, so revising a preset's values cannot change what a selection means.

A preset's **description** is not here. It is a sentence, and sentences belong to the app.

---

## Game Configuration

What a game is played under: a **time control** and the **category** it came from.

The category rides along because the clock header shows it, and re-deriving it from the numbers would
mean the clock knowing about presets.

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

It is digits and separators, so it is the same reading in every language and on every platform.

---

## The Game

`GameService` owns the two clocks, whose turn it is, and what starting, ending a turn, pausing and
resetting mean.

- A fresh game has **not started**, both clocks full. Only a press on **Black's** half begins play.
- Pressing the **running** half ends that turn and starts the opponent's.
- The **increment goes to the player who just moved**, never the one about to move.
- **Pause** freezes the running clock; **resume** starts it again on the same turn.
- **Reset** returns both clocks to full time and the game to not started.
- A clock reaching zero **flags**: the game finishes and the opponent wins on time. Nothing else
  changes — no clock runs, and presses do nothing.

**Remaining time is computed from a monotonic instant**, never accumulated tick by tick, so a
90-minute game does not drift and backgrounding cannot cheat. The ticker exists only to notice that
zero has been passed; it never subtracts.

### Seams

Two dependencies are injected so the rules can be tested without waiting:

| Seam | What it abstracts |
|---|---|
| `TimeSourceProtocol` | The current instant. `ContinuousClock` in the app. |
| `TickerProtocol` | The repeating wake-up while a clock runs. |

This is what lets a 90-minute game be played out in milliseconds.

---

## Presenters

Both screens' presenters live here, so both platforms show the same thing at the same moment.

**`SetupPresenter`** holds the selection. It exposes the presets in display order with the selected
one marked, and the selected ruleset on its own for the start bar. Selecting is by **id**; starting a
game routes with the configuration the selection describes, and leaves the selection alone.

**`ClockPresenter`** maps the game's state into what each half shows — the side, its state, and the
time reading in whichever face is chosen.

- A half is **awaiting start**, **to move**, **low time**, **waiting** or **flagged**.
- **Low time** is under ten seconds, or a tenth of base time in games too short for ten seconds to
  mean much.
- The face toggle — **digital** or **analog** — is presenter state, and switching it mid-game changes
  nothing about the clock.
- **Pause** is shown while the game is paused. **Reset** asks first, but only while a game is
  actually in progress; otherwise it just resets.
- The move number is Black's completed moves plus one.

### What a presenter hands over

A view model carries **what to draw and what to report back**, never a domain type: a side rather than
a player, an id rather than a preset, a category token rather than its name. The app turns those into
words.

The analog face gets `DialHands` — minute and second hand angles in degrees — rather than a duration,
so the geometry is computed once for both platforms.

---

## Navigation

Each feature's routing protocol lives here, because the presenter that calls it does:

- `SetupRoutingProtocol` — enter the clock with a game configuration.
- `ClockRoutingProtocol` — leave the clock.

Whatever hosts the presenters implements them. On iOS that is the app's router.

---

## Platform Constraints

- **No `SwiftUI`, no `CoreUI`, no `UIKit`.** The only import in the module is `Observation`.
- **No `LocalizedStringResource`, and no `String(localized:)`.** A presenter that resolved copy would
  have chosen words for a platform it cannot see.
- The module builds for iOS and for `aarch64-unknown-linux-android28`, and presenter isolation is the
  same on both.
