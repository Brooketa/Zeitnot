# Zeitnot — Project Overview

## What Is Zeitnot?

Zeitnot is an iOS **chess clock for two players sharing one device**. The players pick a time
control before the game, lay the device flat between them, play with each side tapping their own
half of the screen, and review how the time was spent once the game is over.

The name is the chess term for *time trouble* — the state of having almost no time left on the
clock.

## Core Concept — The Ruleset

A **ruleset** is the time control a game is played under. It is chosen on the setup screen and
governs everything the clock does. In this pass a ruleset is always **a base time plus a per-move
increment** (e.g. Classical `90 | 30` — 90 minutes each, plus 30 seconds per move).

Rulesets come from two places:

- **Preset rulesets** — a grouped list, each preset showing its category, time control, description
  and selection state
- **Custom** — the player builds their own from a base time and an increment via steppers

Exactly one ruleset is selected at all times. Adjusting either custom stepper selects the custom
ruleset. The selection, the custom values and the sound preference all survive an app relaunch.

## Core Concept — The Turn Record

While a game runs, the clock records **every completed turn and how long it took**. This record is
the single source of data behind both review screens — neither does any timing of its own. It is
produced by the clock screen and read by the turns and statistics screens.

## Screens

The app is four screens, not a tab bar. Setup → Clock, and the two review screens hang off the
game-over banner.

### Setup Screen (portrait)

The launch screen. Holds the **PRESET RULESETS** list, the **CUSTOM** section, a **PREFERENCES**
section with the sound preference, and a sticky **START GAME** bar that names the current selection
and opens the clock screen. Returning from the clock leaves the selection and preferences unchanged.

### Clock Screen (landscape)

The only landscape screen, and the heart of the app. Two equal white cards sit side by side —
**White left, Black right** — each a full-height tap target, **both reading upright** (neither is
rotated). A native navigation bar carries the back button, the ruleset as its title
(`● CLASSICAL · 90 | 30`) and the move number (`MOVE 1`) as a trailing item. A centred control bar
below holds `PAUSE`, `RESET` and a sound button.

This screen owns start, stop, turn switching, increment, pause, reset, the low-time warning,
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
- A clock reaching zero ends the game; the opponent wins on time

When a clock reaches zero a **result banner appears over the clock screen** — there is no automatic
navigation away. The banner offers `REMATCH`, `TURNS` and `STATISTICS`.

### Turns Screen (portrait)

Every turn of a finished game, one row per turn, with that turn's duration. The player is conveyed
by **which side of the row the time sits on** — White leading edge, Black trailing edge — with a
`WHITE` … `BLACK` column header as the only explanation of the convention. A pinned footer shows
each player's total time used. A finished game with no completed turns shows an empty state.

Answers *"what happened on each turn"*.

### Statistics Screen (portrait)

Five per-player metrics for a finished game, laid out side by side for at-a-glance comparison:
**time used, moves played, average turn, longest think, fastest turn**.

Answers *"what can I learn about the game overall"* — which is why it is separate from Turns.

Both review screens are reachable **only** from the game-over banner. Neither is reachable during a
running game, and neither updates live. Back from either returns to the clock with the banner
intact.

## Behavioural Rules Worth Knowing

These are cross-cutting product decisions, not implementation details:

- **Time used includes the final incomplete turn** — a game ends mid-turn and the clock consumed
  that time. Moves played, average turn, longest think and fastest turn use **completed turns
  only**. A player can therefore show 9 moves at a `0:00.7` average while time used reads `0:12`.
  That is correct, not a bug.
- **Zero-move metrics report `0:00`**, not a dash — so no calculation or table carries a special
  empty case. Consequence: `0:00.0` is both a genuinely fast turn and what a player with no moves
  reports; the moves-played row is what distinguishes them.
- **Time formatting** — individual turn durations carry tenths (`0:01.5`); totals and time used do
  not (`0:13`). Everything scales to `H:MM:SS` for classical games. **One shared formatting helper**
  serves the clock, turns and statistics screens.
- **One sound preference, two entry points** — the setup screen's toggle and the clock screen's
  speaker button change the same stored setting and stay in sync.
- **No haptics anywhere.** The device lies flat in landscape between the two players; a vibration on
  every clock switch risks shifting or dislodging it. Sound only.

## Technical Notes

- Platform: **iOS 26.5 (SwiftUI)**, iPhone and iPad
- **Portrait throughout, except the clock screen, which is landscape**
- **Native navigation everywhere** — the system navigation bar and its back button on every screen.
  This is a deliberate override of the mockups, which draw a custom circular chevron on the clock
  and statistics screens. It buys correct back-swipe, large-title transitions and accessibility for
  free. More broadly: **reuse as much as possible from Apple, and build custom only where the design
  genuinely requires it.**
- The clock **must not drift**, and must survive backgrounding
- Statistics must not break on a zero-move game
- No persistence beyond the current session — there is no saved game history
- Colours should be defined so that adding **dark mode** later does not mean touching every screen

## Not In This Pass

Deferred deliberately, with tickets on the board:

- **Analog clock face** and the `DIGITAL | ANALOG` segmented control (**ZN-48**). The toggle is not
  built — nothing on screen should promise a face that does not exist. Three open design questions
  must be answered before it starts: how remaining time maps onto a dial when a `1|0` bullet game
  and a `90|30` classical game need very different mappings; whether a numeric readout accompanies
  the dial, given a dial cannot show the tenths that matter most in the last ten seconds; and what
  the low-time warning becomes in analog mode.
- **Multi-stage time controls** (**ZN-53**) — additional time after a given move number, restoring
  the true Classical `90|30`. Stage time triggers **per player** (White on completing their own move
  40, Black on theirs), and a player who flags before the boundary never receives it. Multi-stage in
  the *custom* configuration UI is explicitly out of scope: presets carry stages, "Build your own"
  does not.

Because of the second item, **the app currently ships a Classical preset that is not the standard
Classical format** — its copy reads "90 minutes each, plus 30s per move."

Considered and set aside, with no ticket: dark mode, game history across sessions, highlighting the
longest think on the Turns screen, and a stage editor in custom configuration.

## Source Of Truth

The board is the **Zeitnot** Jira project (`ZN`, https://thorssons.atlassian.net/browse/ZN).
**ZN-1** is the product reference this overview is derived from — a reference issue, not a unit of
work, with no child tasks. All implementation lives under the screen Epics: **ZN-2** Setup,
**ZN-23** Clock, **ZN-37** Turns, **ZN-43** Statistics.

Tickets describe **what must be true when the work is done** — behaviour, copy, states, edge cases.
They deliberately do not prescribe types, properties, method names or architecture; those are
decided during implementation. Where a technical property genuinely matters to the product, it is
stated as a requirement to satisfy, not a design to follow.
