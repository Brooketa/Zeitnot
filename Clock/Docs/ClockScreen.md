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

The screen shell: a navigation bar naming the ruleset, over the app's background. Below it, nothing
yet — but the module now owns the **clock face**, the card one player reads their time from. It is
built; placing two of them side by side is the layout ticket's job.

The screen stays deliberately empty below the bar until then. The **game itself** now runs behind it
— the clocks, the turns and the transitions described below — but nothing on screen reads it yet.
The tap handling, the control bar, the move number and the game-over banner each arrive with their
own ticket, and until they do nothing on screen promises behaviour that is not there.

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

## Navigation Bar

The system navigation bar, not a custom one, carrying the ruleset as its title:

    ● CLASSICAL · 90 | 30

The bullet, the middle dot and the uppercasing are the **clock's** presentation. The configuration
supplies the category in natural casing (`Classical`) and two integers; this screen composes the
rest, so the setup module has no say in how the clock names a ruleset.

The reading is held in the module's String Catalog under a named key, so neither the presenter nor
any view writes a `|` or a `·` as a Swift literal. The Setup module keeps its own entry for the same
`90 | 30` reading — String Catalog symbols are generated per target, so the two cannot share one
until ZN-60 decides where shared copy lives. That duplication is the reason ZN-60 exists and is the
one place the two modules can drift.

Because a navigation title is a string rather than a view, the **presenter** uppercases the
category. The setup screen does the same thing with a text-case modifier, which a title bar does not
offer.

The title is displayed **inline**. The large title belongs to a screen being read top to bottom; the
clock's bar is chrome above a fixed layout.

The **back button** is the system's, and appears because the screen is pushed rather than presented.

### Not built yet

- The **move number** (`MOVE 1`) as a trailing item (ZN-28), reading the per-player move count the
  game state carries (ZN-24).

---

## Clock Face

One player's card: their name above their remaining time, centred on white, 26pt radius, soft
shadow. Nothing else — the mockup's `0 MOVES · +30S` line is dropped, since the increment already
reads from the navigation bar.

The card is passive. It renders what it is given and owns no timing and no tap handling. The layout
places it (ZN-28); what a tap means is ZN-29.

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

Awaiting start and waiting look identical today and are still two states, because ZN-29 must make
the not-started screen show *which half to press*. Only that case changes when it does.

Ring and name cross-fade over 200ms. The digits never animate — a time that eases into place is
wrong for the length of the animation.

Two more states arrive with the low-time warning, one with flag fall. See **Not Built Yet**.

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

- **Two player cards** — equal halves, White left and Black right, both reading upright, each a
  full-height tap target.
- **Backgrounding** — a running game must come back paused and still correct after the app has been
  suspended or interrupted, and the screen must not sleep through a long think.
- **Tap handling** — tapping the active player's half ends their turn and starts the opponent's.
  Black presses to start White's clock, and the not-started state has to show which half to press.
- **Control bar** — `PAUSE` and `RESET`, centred below the cards. No time is consumed while paused,
  and reset returns both clocks to full base time with the move counts zeroed, asking for
  confirmation only when there is a game in progress to lose.
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
- [x] The face owns no timing and no tap handling.
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
