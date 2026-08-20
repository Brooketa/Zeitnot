# Zeitnot — Project Overview

## What Is Zeitnot?

Zeitnot is an iOS **chess clock for two players sharing one device**. The players pick a time
control before the game, lay the device flat between them, and play with each side tapping their own
half of the screen.

The name is the chess term for *time trouble* — the state of having almost no time left on the
clock.

> **Scope was cut on 2026-08-20.** The app is **two screens**, not four. Everything removed is
> deferred with a ticket on the board, never deleted — see [Deferred Work](#deferred-work). Do not
> reintroduce cut scope because a mockup or an older document shows it.

## Core Concept — The Ruleset

A **ruleset** is the time control a game is played under. It is chosen on the setup screen and
governs everything the clock does. A ruleset is **a base time plus a per-move increment** (e.g.
Classical `90 | 30` — 90 minutes each, plus 30 seconds per move).

Rulesets come from **one** place: a grouped list of six **presets**, each showing its category, time
control, description and selection state. Exactly one is selected at all times, and Bullet `1 | 0` is
selected on every launch.

Building your own ruleset is deferred (**ZN-18**), and so is remembering the selection between
launches (**ZN-20**).

## Screens

Two screens. Setup → Clock, and back.

### Setup Screen (portrait)

The launch screen, and essentially complete. Holds the **PRESET RULESETS** list and a sticky
**START GAME** bar that names the current selection and opens the clock screen. Returning from the
clock leaves the selection unchanged for the rest of the session.

There is no `CUSTOM` section and no `PREFERENCES` section.

### Clock Screen (landscape)

The only landscape screen, and the remaining work in the project. Two equal white cards sit side by
side — **White left, Black right** — each a full-height tap target, **both reading upright**
(neither is rotated). A native navigation bar carries the back button, the ruleset as its title
(`● CLASSICAL · 90 | 30`) and the move number (`MOVE 1`) as a trailing item. A centred control bar
below holds **`PAUSE` and `RESET`** — two buttons, not three.

This screen owns start, stop, turn switching, increment, pause, resume, reset, the low-time warning,
backgrounding, flagging, and the game-over state — treated as one coherent behaviour rather than
separate features.

Key rules:

- Tapping the **active** player's half ends their turn and starts the opponent's
- **Black presses to start White's clock** — the physical chess clock convention, where pressing
  your own side ends your turn. From the not-started state only a tap on Black's half begins the
  game, and because that is not obvious on screen, the not-started state must show which half to
  press
- The increment is credited to the player **who just moved**, not the one about to move
- No time is consumed while paused, and the clock must still be correct after backgrounding
- A clock reaching zero **flags**: the game ends and the opponent wins on time

When a clock flags a **result banner appears over the clock screen** — there is no automatic
navigation away. The banner offers **`REMATCH`** and nothing else.

## Behavioural Rules Worth Knowing

Cross-cutting product decisions, not implementation details:

- **The clock keeps per-player move counts only.** That is all `MOVE n` and the increment need.
  Recording each turn's duration served the two review screens and is deferred to **ZN-71**.
- **Time reads in whole seconds** — `1:30:00 · 59:59 · 3:07 · 0:08 · 0:00`. `h:mm:ss` from an hour
  up, `m:ss` below it. **No tenths anywhere**; they were asked for under a minute and deliberately
  dropped in the first pass, and adding them later changes one accessor and no screen. The reading
  **truncates towards zero, never rounds** — 1.9 seconds left reads `0:01`, because showing a player
  time they do not have is the one direction a clock must not err in.
- **One shared time reading** lives in `Core` as an accessor on `Duration`, so nothing can diverge.
- **Elapsed real time is the source of truth for the clock.** Accuracy must not depend on how often
  the display updates. A clock that accumulates error one frame at a time is a broken chess clock,
  and it is very hard to retrofit — this is the single most important technical property in the app.
- **No sound anywhere.** The switch tick, the flag sound and the speaker button are all deferred
  (**ZN-33**), as is the preference that would govern them (**ZN-19**).
- **No haptics anywhere.** The device lies flat in landscape between the two players; a vibration on
  every clock switch risks shifting or dislodging it. This is **rejected outright, not deferred** —
  note that the original reasoning read "sound only", and the app now has no sound either.

## Technical Notes

- Platform: **iOS 26.5 (SwiftUI)**, iPhone and iPad
- **Portrait throughout, except the clock screen, which is landscape.** A screen declares this with
  the single modifier `CoreUI` provides and never names a window scene or an orientation mask. On
  iPad every orientation is allowed everywhere.
- **Native navigation everywhere except the clock screen**, which carries a custom header (ZN-76).
  The setup screen uses the system bar and its back button. More broadly the rule still holds:
  **reuse as much as possible from Apple, and build custom only where the design genuinely requires
  it** — the clock screen is where it genuinely does, for two reasons. Its dialogs are presented
  inside the view so they can fade and blur, and a system bar would always draw on top of them; and
  its title carries a **live status dot**, which a navigation title cannot express because it is a
  plain string.
- **Back-swipe is disabled on the clock screen.** The device lies flat between two players tapping
  for a whole game, so an edge swipe is far too easy to make by accident — and it would abandon a
  game with no confirmation and no history to return to. This is the one place the app gives up a
  system gesture on purpose.
- The clock **must not drift**, and must survive backgrounding
- **Nothing persists.** No saved configuration and no saved game history
- Colours are defined as colorsets so adding **dark mode** later does not mean touching every screen

## Deferred Work

Nothing here is cancelled. Each item has a ticket carrying its full specification and reasoning.

### Cut on 2026-08-20

| What | Ticket | Consequence |
|------|--------|-------------|
| Persistence | **ZN-20** | Nothing survives a relaunch; every launch starts on Bullet `1 \| 0` |
| Custom ruleset | **ZN-18** | Six presets, no `CUSTOM` section |
| Sound preference | **ZN-19** | No `PREFERENCES` section on the setup screen |
| Clock sounds and speaker button | **ZN-33** | The clock is silent; the control bar is `PAUSE` and `RESET` |
| Turns screen | **ZN-37** | Not built, not reachable |
| Statistics screen | **ZN-43** | Not built, not reachable |
| The per-turn record | **ZN-71** | The clock keeps per-player move counts only |

The last one is the subtle one. The turn record was to be produced by the clock and read by both
review screens. With those screens cut it has no consumer, so **ZN-24** was reduced to move counts
and the record moved to **ZN-71**. Either review screen therefore costs two pieces of work, not one
— build ZN-71 into the clock first. The banner lost its `TURNS` and `STATISTICS` actions for the
same reason (**ZN-34**); whichever review screen is built restores its own action.

### Deferred earlier

- **Analog clock face** and the `DIGITAL | ANALOG` segmented control (**ZN-48**). The toggle is not
  built — nothing on screen should promise a face that does not exist. Three open design questions
  must be answered before it starts: how remaining time maps onto a dial when a `1|0` bullet game
  and a `90|30` classical game need very different mappings; whether a numeric readout accompanies
  the dial, given a dial cannot show tenths; and what the low-time warning becomes in analog mode.
- **Multi-stage time controls** (**ZN-53**) — additional time after a given move number, restoring
  the true Classical `90|30`. Stage time triggers **per player** (White on completing their own move
  40, Black on theirs), and a player who flags before the boundary never receives it. Multi-stage in
  the *custom* configuration UI is explicitly out of scope: presets carry stages, "Build your own"
  does not.

Because of the second item, **the app ships a Classical preset that is not the standard Classical
format** — its copy reads "90 minutes each, plus 30s per move."

### Considered and set aside

No ticket exists for these:

- **VoiceOver and accessibility.** Criteria were stripped from ZN-16 and ZN-18 rather than being met
  piecemeal. If taken up it should be one Epic covering every screen, not a criterion scattered
  across a dozen tickets.
- **Dynamic Type.** The design tokens set explicit point sizes on purpose; the type does not scale.
  "Holds at large Dynamic Type sizes" is not a criterion anywhere.
- **Dark mode**, **game history across sessions**, **highlighting the longest think** on a Turns
  screen, and **a stage editor** in custom configuration.

## Source Of Truth

The board is the **Zeitnot** Jira project (`ZN`, https://thorssons.atlassian.net/browse/ZN).
**ZN-1** is the product reference this overview is derived from — a reference issue, not a unit of
work, with no child tasks. Implementation lives under **ZN-2** Setup and **ZN-23** Clock; **ZN-37**
Turns and **ZN-43** Statistics are deferred Epics.

Tickets describe **what must be true when the work is done** — behaviour, copy, states, edge cases.
They deliberately do not prescribe types, properties, method names or architecture; those are
decided during implementation. Where a technical property genuinely matters to the product — the
clock must not drift — it is stated as a requirement to satisfy, not a design to follow.
