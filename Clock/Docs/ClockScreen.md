# Clock Screen

The landscape screen a game is played on. The device lies flat between the two players, each
tapping their own half.

This document is the source of truth for how the screen behaves. Sections marked **Not built yet**
describe intent only — nothing in them is on screen today.

---

## What Exists Today

The screen shell: a navigation bar naming the ruleset, over the app's background. Below it, nothing
yet — but the module now owns the **clock face**, the card one player reads their time from. It is
built; placing two of them side by side is the layout ticket's job.

The screen stays deliberately empty below the bar until then. Everything else the clock does — the
timing, the tap handling, the control bar, the move number and the game-over banner — arrives with
its own ticket, and each one fills in part of this shell. Until then nothing on screen promises
behaviour that is not there.

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

## Navigation Bar

The system navigation bar, not a custom one, carrying the ruleset as its title:

    ● CLASSICAL · 90 | 30

The bullet, the middle dot and the uppercasing are the **clock's** presentation. The configuration
supplies the category in natural casing (`Classical`) and two integers; this screen composes the
rest, so the setup module has no say in how the clock names a ruleset.

The reading is held in the module's String Catalog under a named key, so neither the presenter nor
any view writes a `|` or a `·` as a Swift literal. The Setup module keeps its own entry for the same
`90 | 30` reading — String Catalog symbols are generated per target, so the two cannot share one
until ZN-60 decides where shared copy lives.

Because a navigation title is a string rather than a view, the **presenter** uppercases the
category. The setup screen does the same thing with a text-case modifier, which a title bar does not
offer.

The title is displayed **inline**. The large title belongs to a screen being read top to bottom; the
clock's bar is chrome above a fixed layout.

The **back button** is the system's, and appears because the screen is pushed rather than presented.

### Not built yet

- The **move number** (`MOVE 1`) as a trailing item (ZN-25).

---

## Clock Face

One player's card: their name above their remaining time, centred on white, 26pt radius, soft
shadow. Nothing else — the mockup's `0 MOVES · +30S` line is dropped, since the increment already
reads from the navigation bar.

The card is passive. It renders what it is given and owns no timing and no tap handling. The layout
places it (ZN-28); what a tap means is ZN-29.

**The time** comes from the reading in `Core`, shared with the turns and statistics screens:
`h:mm:ss` from an hour up, `m:ss` below it, whole seconds throughout.

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

Everything below belongs to the Epic's remaining tickets. It is recorded here so the screen's
intended behaviour is legible while the shell is empty, not because any of it is on screen.

- **Two player cards** — equal halves, White left and Black right, both reading upright, each a
  full-height tap target.
- **Timing** — start, turn switching, the increment credited to the player who just moved, and a
  clock that does not drift and survives backgrounding.
- **Tap handling** — tapping the active player's half ends their turn and starts the opponent's.
  Black presses to start White's clock, and the not-started state has to show which half to press.
- **Control bar** — `PAUSE`, `RESET` and a sound button, centred below the cards. No time is
  consumed while paused.
- **Low-time warning** — a pulsing accent border on the running half below ten seconds. The clock
  face gains two more states with it: the running half keeps its fill and gains the border, and the
  *waiting* half below the threshold turns to a tinted fill with darker type — a still warning, since
  only the running side ever animates.
- **Flagging and the game-over banner** — a clock reaching zero ends the game and the opponent wins
  on time. The banner appears over this screen, offering `REMATCH`, `TURNS` and `STATISTICS`; there
  is no automatic navigation away. The flagged half fills solid accent with inverse type, and a
  caption below the digits reads `FLAG FELL` — that caption slot has to be **reserved at full height
  from the start**, or the digits will jump the moment it appears.
- **The turn record** — every completed turn and how long it took, produced here and read by the
  turns and statistics screens.

No haptics anywhere on this screen: the device lies flat between the players, and a vibration on
every clock switch risks shifting it. Sound only.

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
- [x] Its time reading comes from `Core`, so the clock, turns and statistics screens cannot diverge.
- [x] The reading switches format at the hour and the minute, and carries whole seconds only.
- [x] The digits are monospaced and unscaled, so they do not shift as they count.
- [x] `1:30:00` fits a half card on the smallest supported iPhone without truncating.
- [x] To move and waiting are distinguishable at a glance, by ring and name colour rather than fill.
- [x] The face owns no timing and no tap handling.
