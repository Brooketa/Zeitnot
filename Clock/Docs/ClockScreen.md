# Clock Screen

The landscape screen a game is played on. The device lies flat between the two players, each tapping
their own half. This document describes what the screen does today.

---

## Layout

```
‹  ● CLASSICAL · 90 | 30                                    MOVE 1

        WHITE                              BLACK
        3:00                                3:00
                                      PRESS TO START

         DIGITAL | ANALOG   PAUSE   RESET
```

- **Header** — a custom header, not the system bar. Back control, ruleset, move number.
- **Two equal cards**, White left, Black right, both upright. Each is a full-height tap target.
- **Control bar** — the `DIGITAL | ANALOG` control, `PAUSE` and `RESET`, centred as one row
  beneath.

---

## Configuration

The screen is handed a **game configuration** when constructed and holds it for the life of the
game: the time control, plus the category name of the ruleset it came from. It is a value taken when
START GAME was tapped, so changing the setup selection afterwards cannot reach a running game.

The view is constructed with a presenter, the presenter with the configuration.

---

## The game

| State | Meaning |
|---|---|
| **Not started** | Both clocks full, nothing counting |
| **Running** | Exactly one clock counting down |
| **Paused** | Neither counting; the player to move is remembered |
| **Finished** | A clock reached zero; the opponent won on time |

| Transition | What happens |
|---|---|
| **Start** | White's clock begins. No move is recorded — pressing to begin is not a turn |
| **End turn** | The mover's time is banked and increment credited, their move count rises, the opponent starts |
| **Pause** | The running clock's time is banked where it stands |
| **Resume** | The same turn continues — no move recorded, no time consumed |
| **Reset** | Both clocks to full base time, move counts to zero, not started |

Only one clock can run, because the running state carries a single player and a single instant — two
at once cannot be written down. A finished game ignores every transition but reset.

The screen keeps **per-player move counts** and nothing more.

### Time is elapsed, never accumulated

A running clock's remaining time is **computed on read**: what it held when the turn began, less the
real time since. Nothing sums ticks, so a 90 minute game accumulates no drift and accuracy does not
depend on how often the display refreshes.

Flag fall is therefore **derived, not detected** — a game whose running clock has reached zero *is*
finished at that instant, whether or not anything looked. Zero is exact and a clock never reads
negative.

Time comes from a monotonic source that keeps counting while the app is suspended, so a system clock
change cannot move a game and backgrounding cannot gain a player time. The source is injected, which
is what lets a 90 minute game be played out in milliseconds under test.

---

## Header

- **Back control** — circular Liquid Glass, ink chevron, no tint, 44pt. Carries an accessibility
  label, since a glyph alone says nothing.
- **Status dot** — accent while a clock counts down, grey before the first press, while paused and
  once finished. Cross-fades over 200ms. It is a view, never a character in the copy.
- **Ruleset** — `CLASSICAL · 90 | 30`. The middle dot and the uppercasing are presentation; the
  configuration supplies a category in natural casing and two integers.
- **Move number** — counts *chess* moves, so it advances when **Black** presses, not White.

Hiding the system bar also disables back-swipe, which this screen wants: a stray edge swipe would
abandon a game with no confirmation and nothing to return to. Leaving is a deliberate tap.

---

## Clock face

One player's card: name above remaining time, centred on white, 26pt radius, soft shadow.

The card renders what it is given and reports that it was pressed. It owns no timing and no rules.
The presenter supplies data only; each face derives its own colours from the state it is handed.

**The card shows one of two faces**, chosen by a display mode. Both read the same remaining time.

| Face | Shows |
|---|---|
| Digital | The shared reading from `Core` — `h:mm:ss` from an hour up, `m:ss` below, whole seconds, truncating towards zero |
| Analog | A dial: supplied artwork under a minute hand and a second hand |

The mode is chosen with the `DIGITAL | ANALOG` control in the control bar. **Digital is the
default.** Selecting a mode changes both cards at once — the two are never in different modes.

The control is **custom, not `UISegmentedControl`** — the platform control has a fixed 32pt height
and offers no way to fill the selected segment with ink, so it could match neither the design nor the
buttons beside it. It is a muted capsule track holding two segments, the selected one an inset ink
capsule with inverse label; the selection slides between them with `matchedGeometryEffect`. Its
labels are a size smaller than the buttons', so it reads as a mode switch rather than a third
button.

Switching is presentation only. It never pauses, resumes, resets, switches turns or touches a move
count, and doing it mid-game while a clock runs is expected and safe. It also works while paused and
once the game is over.

- **Digits never move as they count** — monospaced, one fixed size, no scaling.
- **The caption slot holds its height** whether or not it has text, so nothing jumps.

| State | Card |
|---|---|
| Awaiting start | Muted name, muted face. Black's card reads `PRESS TO START` |
| To move | Accent name, ink face, accent second hand, steady accent ring |
| Low time | As to-move, ring pulsing |
| Waiting | Muted name and face, no ring |
| Flagged | Fills accent, inverse type and face, reads `FLAG FELL` |

To-move and waiting differ by ring and name colour rather than fill, so neither card shouts.

### The dial

An ordinary clock face read **backwards from the 12**: each hand sits behind the 12 by the remaining
time and travels clockwise as it is spent, so both reach the 12 at zero — the way a physical chess
clock is set so the flag falls at the top of the hour.

Two hands, no hour hand — a **minute** hand on a 60 minute revolution and a **second** hand on a 60
second one. Bullet and blitz are read off the second hand, as they are on a real clock in time
trouble.

**`90 | 30` is ambiguous on the dial.** 90 minutes and 30 minutes both put the minute hand on the 6,
and without an hour hand nothing separates them until the hand crosses the 12. It is the only preset
affected — every other base time is under an hour. Accepted deliberately, and pinned by a test.

**The hands are placed, never animated.** Every redraw positions them at the absolute angle for that
instant, so there is no drift and no catch-up sweep after backgrounding. Animation is explicitly
suppressed on the rotation: the second hand wraps 0° → 360° once a minute, and any inherited
animation turns that wrap into a full spin.

**The artwork carries no colour of its own** — it is a template, tinted per state, which is how the
dial greys while waiting and inverts whole when flagged.

---

## Pressing

- Pressing the **player to move's** half ends their turn and starts the opponent's.
- From not started, **only Black's half** begins the game — and it starts White's clock. That is the
  physical chess clock convention: pressing your own side ends your turn.
- Every other press is ignored, including presses once the game is over.
- A double press switches once. No debounce is needed, because the second press lands on a half that
  is no longer to move.

---

## Pausing

`PAUSE` stops the running clock where it stands and fades in a dialog over a blurred, dimmed board.
It reads `PAUSED`, names the player who will resume, and offers `RESUME`.

No time is consumed while it is up, however long, and resuming continues **the same turn** — move
counts unchanged, no increment credited.

The dialog covers the **whole screen**, header and control bar included, so `RESUME` is the only
live control while paused. Anything else needs the game resumed first.

---

## Resetting

`RESET` returns the game to not started: both clocks to full base time, both move counts to zero,
Black to press first.

- While a game is **running**, it asks first — a dialog offering `RESET` and `CANCEL`. Cancelling
  leaves the game exactly as it was, clock still counting.
- Once **finished**, it resets immediately. A finished game has nothing left to lose, and this is
  how the players start their next one.
- While **paused** it is unreachable, since the pause dialog covers the control bar.

---

## Flagging

A clock reaching zero ends the game and the opponent wins on time.

There is **no banner and no navigation away** — the result is a state of the card itself, so both
final times stay readable and the players keep looking at the position they finished in. The winner
is conveyed by which half went red, so there is no result sentence to write or translate.

| While over | |
|---|---|
| Pressing either half | ignored |
| `PAUSE` | disabled, and visibly so, keeping the bar's shape |
| `RESET` | works, without confirmation |

---

## The low-time warning

When the player to move drops below the threshold, their half's ring pulses.

- The threshold is **ten seconds**, or a tenth of base time for very short games — a `1 | 0` bullet
  game should not spend a sixth of itself in the warning state.
- It applies only to the player whose clock is actually running.
- It clears on switching, pausing, resetting and flagging.

---

## Orientation

This is the only landscape screen. It declares that with one `CoreUI` modifier and never names a
window scene or an orientation mask. The app is portrait again once the screen is left. On iPad
every orientation is allowed everywhere.

---

## Localization

Every user-facing string resolves from the module's String Catalog through a generated symbol. No
view writes display copy as a Swift literal, and no `|`, `·` or `●` appears in the copy — those are
presentation applied by the view.
