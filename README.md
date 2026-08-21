<img width="120" height="120" alt="AppIcon-120" src="https://github.com/user-attachments/assets/67be8f1e-c800-4559-bd4a-6541c811562d" />

# Zeitnot

A two-player chess clock for iPhone. Named for the German term for having almost no time left on the clock.

- **Two halves, one running.** Lay the device flat between you; each player taps their own half
- **Six preset rulesets**, Bullet through Classical
- **Two faces**, digital and analog, switched mid-game
- **Nothing else.** No accounts, no board, no history to manage

## Rulesets

| Category | Ruleset | What it means |
|---|---|---|
| Bullet | `1 \| 0` | One minute each. Sudden death. |
| Blitz | `3 \| 2` | Three minutes, plus 2s per move. |
| Blitz | `5 \| 0` | Five minutes each, classic blitz game. |
| Rapid | `10 \| 0` | Ten minutes each, no increment. |
| Rapid | `15 \| 10` | Fifteen minutes, plus 10s per move. |
| Classical | `90 \| 30` | 90 minutes each, plus 30s per move. |

Classical here is base-plus-increment, **not** the standard two-stage Classical format. The copy in the app says as much.

## How the clock works

- **Black presses to start.** From a fresh game only a tap on Black's half begins play, following the physical chess clock convention. That half reads `PRESS TO START`
- **Tapping the running half** ends that player's turn and starts the opponent's
- **The increment goes to the player who just moved**, never the one about to move
- **Under ten seconds**, or a tenth of base time in very short games, the running half pulses red
- **A clock reaching zero flags.** The game ends, the opponent wins on time, and the losing half fills accent and reads `FLAG FELL`. Nothing navigates away
- **`PAUSE`** stops the clock behind a full-screen dialog; `RESUME` is the only way out
- **`RESET`** returns both clocks to full time, asking first if a game is running

## Screens

### Set the clocks

<img height="640" alt="setup" src="https://github.com/user-attachments/assets/a621be67-7258-4ae5-819c-80732c208296" />

Portrait. Pick a ruleset, then START GAME.

### Clock

Landscape, one half per player. A toggle under the clocks switches the face mid-game.

**Digital**

<img width="640" alt="clock-digital" src="https://github.com/user-attachments/assets/84f0de72-f4c5-4253-8b0f-479ad58d62d5" />

**Analog**

<img width="640" alt="clock-analog" src="https://github.com/user-attachments/assets/2bc4094a-98de-44f8-8473-455c7aa2e020" />

The waiting half greys out; the half to move carries the accent ring.

**Flag fell**

<img width="640" alt="flag-fell" src="https://github.com/user-attachments/assets/5f3988d9-f64e-4606-9a36-343f1325babf" />

**Pause and reset**

<img width="640" alt="paused" src="https://github.com/user-attachments/assets/013cc810-04e0-4830-997f-65618de749f5" />

<img width="640" alt="reset" src="https://github.com/user-attachments/assets/858f2741-e24a-43a7-8dcd-50c9d7c86de0" />

<sub>The flag-fell, paused and reset captures predate the face toggle, so their bottom row shows only PAUSE / RESET.</sub>

## Architecture

One local Swift package per module, and a screen is layered View → Presenter → Service.

```
App  ──▶  Setup · Clock  ──▶  CoreUI  ──▶  Core
```

- **The Service holds the game.** `GameService` owns the two clocks, whose turn it is, and what starting, passing, pausing and resetting mean. The Presenter turns that into the strings a view renders; the View only reports taps back
- **Remaining time is computed from a monotonic instant**, never accumulated tick by tick, so a 90-minute game doesn't drift and backgrounding can't cheat
- **Features never import each other.** Each declares a routing protocol; `AppRouter` satisfies both

The clock screen carries a custom header and disables back-swipe, so a stray gesture can't abandon a game. Every other screen uses native navigation.

## Design

Flat, single accent, San Francisco throughout. Colours are colorsets, so dark mode later doesn't mean touching every screen.

<img height="520" alt="swatches" src="https://github.com/user-attachments/assets/02da4e33-1b8b-4893-a320-8a7c8c54e0c7" />
