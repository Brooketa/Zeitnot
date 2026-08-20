# Clock Screen

The landscape screen a game is played on. The device lies flat between the two players, each
tapping their own half.

This document is the source of truth for how the screen behaves. Sections marked **Not built yet**
describe intent only — nothing in them is on screen today.

> **Scope was cut on 2026-08-20.** This screen and the setup screen are the whole app. The turns and
> statistics screens, all sound, and persistence are deferred with tickets — see the project
> overview. Nothing below promises them.

---

## What Exists Today

The screen is playable. Two cards side by side, the ruleset and the move number in the navigation
bar, `PAUSE` and `RESET` beneath — and pressing a half switches the turn, so a game runs from the
first press until a clock reaches zero.

What is still missing is what happens *around* a game: the pause overlay, the reset confirmation,
the low-time warning, the game-over banner, and correct behaviour across backgrounding. Each has its
own ticket, and until they land nothing on screen promises them.

The screen is reachable. START GAME on the setup screen pushes it with the configuration of the
ruleset that was selected at the moment of the tap (ZN-62), and the system back button returns to
setup with that screen exactly as it was left.

---

## Configuration

The screen does not choose what a game is played under — it is handed a **game configuration** when
it is constructed, and holds it for the life of the game.

That configuration carries the time control and the **category name** of the ruleset it came from
(`"Classical"`). It is a value, taken at the moment START GAME is tapped, so changing the selection
on the setup screen afterwards cannot reach a game already under way.

The presenter is constructed with the configuration and the view is constructed with the presenter.
The view never builds its own presenter, so whoever routes to the screen decides what game is being
played.

---

## The Game

The screen owns a **game**: two clocks, whose turn it is, and how many moves each player has
completed. Nothing more is kept — the per-turn record was cut to ZN-71 with the review screens.

### States

| State | What it means |
|---|---|
| **Not started** | Both clocks full, nothing counting |
| **Running** | Exactly one clock counting down |
| **Paused** | Neither counting; the player to move is remembered |
| **Finished** | A clock reached zero; the opponent won on time |

Only one clock can be running, because the running state carries a single player and a single
instant. Two clocks counting at once is not guarded against — it cannot be written down.

### Transitions

| Transition | What happens |
|---|---|
| **Start** | White's clock begins. No move is recorded — pressing to begin is not a turn |
| **End turn** | The mover's time is banked and increment credited, their move count rises, the opponent starts |
| **Pause** | The running clock's time is banked where it stands |
| **Resume** | The same turn continues — no move recorded, no time consumed by the pause |
| **Reset** | Both clocks to full base time, move counts to zero, game not started |

The increment goes to the player **who just moved**, and only on a completed move. A player whose
clock reaches zero mid-turn never completes it, so they are credited nothing. A finished game
ignores every transition but reset.

### Time is elapsed, never accumulated

A running clock's remaining time is **computed on read**: what it held when the turn began, less the
real time since. Nothing sums ticks, so there is no drift to accumulate over a 90 minute game, and
accuracy does not depend on how often the display refreshes or on a timer firing on schedule.

**Flag fall is derived, not detected.** A game whose running clock has reached zero *is* finished at
that instant, whether or not anything looked. Zero is therefore exact, and a clock never reads
negative.

Time comes from a monotonic source that **keeps counting while the app is suspended**, rather than
from the wall clock. A system clock change therefore cannot move a game's remaining time, and a
player cannot gain any by backgrounding the app mid-turn — which is most of what ZN-36 needs. The
source is injected, which is what lets a 90 minute game be played out in milliseconds under test
instead of in real time.

---

## Header

A **custom header**, not the system navigation bar, which this screen hides:

    ‹  ● CLASSICAL · 90 | 30                                    MOVE 1

**The back control** is a circular Liquid Glass button with an ink chevron and no tint. It carries
an accessibility label, since a glyph alone says nothing to VoiceOver.

**The dot is a running indicator**, not decoration: accent while a clock is counting down, grey
before the first press, while paused and once the game is over. It cross-fades over 200ms.

**The ruleset** reads `CLASSICAL · 90 | 30`. The middle dot and the uppercasing are the clock's
presentation — the configuration supplies a category in natural casing and two integers. The reading
lives in the module's String Catalog under a named key, so no view writes a `|` or a `·` as a Swift
literal. Setup keeps its own entry for the same reading until ZN-60 decides where shared copy lives.

**The move number** reads `MOVE 1` from the start and counts *chess* moves rather than turns: a move
is White's turn together with Black's reply, so it advances when **Black** presses, not White.

### Why it is not the system bar

Two reasons, either of which would be enough.

A navigation title is a **string**, so the status dot could not be a coloured view — it was a literal
`●` inside the copy, rendering in one colour and unable to say anything. Presentation had been baked
into a translatable string.

And the screen's dialogs are presented **inside** the view, which is what lets them fade and blur
rather than slide. A system bar draws above that, so the back button stayed live over a paused game.

Hiding the bar also **disables back-swipe**, which this screen wants: the device lies flat between
two players tapping for a whole game, and a stray edge swipe would abandon it with no confirmation
and nothing to return to. Leaving is a deliberate tap on the back control.

Both are reversals of `project-overview.md`'s "native navigation everywhere", recorded there too.

---

## Clock Face

One player's card: their name above their remaining time, centred on white, 26pt radius, soft
shadow. Nothing else — the mockup's `0 MOVES · +30S` line is dropped, since the increment already
reads from the header.

The card is passive in the sense that matters: it renders what it is given, reports that it was
pressed, and decides nothing. It owns no timing and no rules — what a press means is settled above
it.

**The time** comes from the reading in `Core`: `h:mm:ss` from an hour up, `m:ss` below it, whole
seconds throughout, truncating towards zero. It lives in `Core` rather than here so that any screen
which later shows a time reads the same one — the turns and statistics screens are deferred, so the
clock is its only caller today.

**The digits never move as they count.** Monospaced, and one fixed size on every device with no
scaling — so a shorter reading cannot render larger than a longer one. The size fits the longest
reading the app can produce (`1:30:00`) on the smallest supported iPhone, so nothing truncates.

### States

| State | Fill | Name | Digits | Ring |
|---|---|---|---|---|
| **Awaiting start** — before the first tap, nothing running | white | grey | grey | none |
| **To move** — the half counting down, only ever one | white | accent | ink | 3pt accent, inset |
| **Waiting** — frozen where its player passed the turn | white | grey | grey | none |

The turn is shown by the ring and the accent name, never by a dark fill: both players read the
screen from opposite sides of a table.

Awaiting start and waiting share their colours, and are told apart by the **caption**: before the
game starts, Black's card reads `PRESS TO START`, which is how the screen says which half to press.

The caption sits below the digits and **its height is reserved whether or not there is text**, so
nothing moves when one appears or goes. Flag fall reuses the same slot for `FLAG FELL`.

Ring and name cross-fade over 200ms. The digits never animate — a time that eases into place is
wrong for the length of the animation.

Two more states arrive with the low-time warning, one with flag fall. See **Not Built Yet**.

---

## Pressing

A press is a tap anywhere on a half. Each card fills its side of the screen, so there are no dead
zones and nothing to aim at.

**You may only press your own half**, exactly as you may only press your own lever on a physical
clock:

| | Press on White's half | Press on Black's half |
|---|---|---|
| **Not started** | ignored | starts **White's** clock |
| **White to move** | ends White's turn | ignored |
| **Black to move** | ignored | ends Black's turn |
| **Paused or finished** | ignored | ignored |

Black pressing to begin is the physical convention — pressing your own side ends your turn, and the
game opens with Black handing the move to White. Because that is not guessable on a screen, the
not-started state says so: Black's card reads `PRESS TO START`.

**A double press switches once**, and nothing debounces it. The moment White presses, White's half
belongs to the player *not* to move, so the second press of a rapid pair is refused by the same rule
that refuses an opponent's press.

A press is a **view event**, not a domain one. The card reports it, the screen turns it into the
transition it means — start or end turn — and the game itself knows nothing about halves being
tapped. The switch
is applied and published on the press rather than at the next display tick, so there is no lag
between the tap and the opponent's clock running.

---

## Pausing

`PAUSE` in the control bar stops the running clock where it stands, and a dialog fades in over the
board with the clocks blurred behind a scrim. It reads `PAUSED`, names the player whose turn will
resume (`WHITE TO MOVE`), and offers `RESUME`.

No time is consumed while it is up, however long the pause lasts, and resuming continues **the same
turn** — the move counts do not change and no increment is credited.

The clocks cannot be pressed while paused because the dialog is in the way, so that is a matter of
layout rather than a rule the press logic has to enforce. It covers the clocks only — the control
bar stays reachable, so a paused game can still be reset.

The dialog covers the board but **not the navigation bar**, which stays above it — the back button
and the move number remain visible and live while a game is paused. Covering them would mean
replacing the system bar with a custom header, which is a decision for the whole app rather than
this dialog.

---

## Resetting

`RESET` returns the game to not started: both clocks back to full base time, both move counts to
zero, Black to press first. It is reachable while a game runs, while it is paused, and once it has
finished — the pause dialog covers the clocks but not the control bar, so the button stays live
behind it.

**It asks first, but only when there is something to lose.** A game that is running or paused raises
a confirmation dialog; a game that has not started, or one that has already finished, resets
immediately, because there is nothing left to protect.

Cancelling changes nothing at all — and a running clock **keeps counting while the dialog is up**.
Opening a dialog is not a way to stop your own clock; only `PAUSE` does that.

---

## Orientation

This is the **only landscape screen in the app**. It declares that with the single modifier CoreUI
provides and nothing more — it never names a window scene, an interface orientation mask or the app
delegate.

Entering the screen rotates the app to landscape on iPhone; leaving it puts the app back to
portrait, because the modifier gives the orientation back on disappear. On iPad every orientation is
allowed everywhere, this screen included.

One nuance worth recording: the rotation happens when the screen appears on an **already-active**
scene, which is what a pushed screen always is. A build that made this screen the app's launch root
stayed portrait, because at launch there is no active window scene for the service to ask to update
its geometry. That is not a case the app can reach — the clock is always pushed — but it is why the
screen was verified by pushing it rather than by launching into it.

---

## Not Built Yet

The list immediately below belongs to the Epic's remaining tickets and **is** coming. It is recorded
here so the screen's intended behaviour is legible while the shell is empty, not because any of it is
on screen. **Deliberately absent** afterwards is the opposite: things that were cut and are not.

- **Backgrounding** — a running game must come back paused and still correct after the app has been
  suspended or interrupted, and the screen must not sleep through a long think.
- **Low-time warning** — a pulsing accent border on the running half below ten seconds. The clock
  face gains two more states with it: the running half keeps its fill and gains the border, and the
  *waiting* half below the threshold turns to a tinted fill with darker type — a still warning, since
  only the running side ever animates.
- **Flagging and the game-over banner** — a clock reaching zero ends the game and the opponent wins
  on time. The banner appears over this screen offering **`REMATCH` alone**; there is no automatic
  navigation away, and reset dismisses it. The flagged half fills solid accent with inverse type,
  and a caption below the digits reads `FLAG FELL` — that caption slot has to be **reserved at full
  height from the start**, or the digits will jump the moment it appears.

Zero must be reached **exactly**, at the correct instant, regardless of how often the display
refreshes. A clock that only notices it has flagged on the next redraw ends the game late and shows
a negative time on the way there.

### Deliberately absent

Not "not built yet" — cut on 2026-08-20 and tracked elsewhere. Do not add them back because a
mockup shows them.

- **A sound button in the control bar**, a tick on every switch and a distinct flag sound (ZN-33),
  and the preference governing them (ZN-19). The clock is silent and the bar holds two buttons.
- **`TURNS` and `STATISTICS` on the banner** (ZN-37, ZN-43). A button that opens nothing is worse
  than no button; whichever screen is built restores its own action.
- **The turn record** — every completed turn and how long it took (ZN-71). It existed only to feed
  those two screens. This screen keeps **per-player move counts** and nothing more, which is all the
  move number and the increment need.
- **The `DIGITAL | ANALOG` toggle and the dial** (ZN-48).

No haptics anywhere on this screen: the device lies flat between the players, and a vibration on
every clock switch risks shifting it. That is rejected outright rather than deferred — and with
sound deferred too, the clock gives no feedback beyond what is on screen.

---

## Acceptance Checklist

Covering what exists today. Items for behaviour that is not built yet are not listed.

- [x] The `Clock` module depends on `Core` and `CoreUI`, and on no other feature module.
- [x] The view is constructed with a presenter, and the presenter with a game configuration.
- [x] The screen is reached by a push from the setup screen, carrying the ruleset selected at the
      moment START GAME was tapped, and is left by the system back button or back-swipe.
- [x] The navigation bar names the ruleset that was passed in, in the form `● CLASSICAL · 90 | 30`.
- [x] The bullet, the middle dot and the casing are composed by this module, from a category name
      and two integers.
- [x] No user-facing string in this module is a Swift literal.
- [x] The screen presents in landscape on iPhone, and the app is portrait again once it is left.
- [x] The screen declares landscape with one modifier and never names a window scene or an
      orientation mask.
- [x] The title composition is covered by unit tests.
- [x] The clock face shows a player name over a time, and nothing else.
- [x] Its time reading comes from `Core`, so any screen that later shows a time reads the same one.
- [x] The reading switches format at the hour and the minute, carries whole seconds only, and
      truncates towards zero rather than rounding up.
- [x] The digits are monospaced and unscaled, so they do not shift as they count.
- [x] `1:30:00` fits a half card on the smallest supported iPhone without truncating.
- [x] To move and waiting are distinguishable at a glance, by ring and name colour rather than fill.
- [x] The face reports a press and owns no timing and no rules about what a press means.
- [x] A game is not started, running, paused or finished, and a finished game names its winner.
- [x] Only one clock can ever be counting down.
- [x] Ending a turn banks the mover's time, credits their increment, raises their move count and
      starts the opponent.
- [x] The increment is credited only on a completed move, and never to a player who ran out of time
      mid-turn.
- [x] No time is consumed while paused, however long the pause, and resuming continues the same turn.
- [x] Reset returns full base time, zero move counts and a not-started game.
- [x] A clock reaching zero finishes the game exactly at zero, with the opponent the winner, and
      never reads negative.
- [x] Remaining time is computed from elapsed real time, so a 90 minute game accumulates no drift.
- [x] The behaviour is covered by tests that play out a long game without waiting in real time.
- [x] The two cards are equal, fill the screen, and each is a tap target with no dead zones.
- [x] The move number reads `MOVE 1` at the start and advances when Black presses, not White.
- [x] Pressing the half of the player to move switches the turn; every other press is ignored.
- [x] From not started, only a press on Black's half begins the game, and it starts White's clock.
- [x] The not-started state shows which half to press, and the prompt goes once the game is running.
- [x] A double press switches once, without a debounce.
- [x] The caption slot holds its height whether or not it has text, so the digits never jump.
- [x] The press rules are covered by presenter tests that advance time without waiting.
- [x] Pausing raises a dialog naming the player whose turn resumes.
- [x] No time reaches either clock while paused, however long the pause lasts.
- [x] Resuming continues the same turn, leaving the move counts untouched.
- [x] The clocks cannot be pressed while the pause dialog is up.
- [x] Reset restores full base time to both clocks and zeroes both move counts.
- [x] Reset asks for confirmation only when a game is running or paused.
- [x] Cancelling a reset leaves the game exactly as it was, clock still counting.
- [x] After a reset the game behaves like a fresh one, Black pressing first.
- [x] Reset is reachable while running, while paused, and once finished.
- [x] The screen carries a custom header and hides the system navigation bar.
- [x] The back control is Liquid Glass with an ink chevron, no tint, and a VoiceOver label.
- [x] The status dot is accent only while a clock counts down, and grey in every other state.
- [x] No user-facing string in the module contains a `●`.
- [x] Back-swipe does nothing; leaving is a deliberate tap.
