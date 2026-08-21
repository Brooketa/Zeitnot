# Zeitnot — Project Overview

An iOS chess clock for **two players sharing one device**. Pick a time control, lay the device flat
between you, and each player taps their own half. The name is the chess term for *time trouble*.

This document describes **what is built**, and nothing else.

---

## The app is two screens

| Screen | Orientation | What it does |
|---|---|---|
| **Setup** | Portrait | Pick one of six preset time controls, then START GAME |
| **Clock** | Landscape | Play the game — the clock and every rule it enforces |

Setup pushes Clock; the clock's back control returns. The selection survives for the session.

---

## Modules

```
App  ──▶  Setup / Clock  ──▶  CoreUI  ──▶  Core
```

Feature modules never import each other. Each is a local Swift package at the repository root.

| Module | Holds |
|---|---|
| `Core` | Time control, game configuration, the shared time reading. No UI. |
| `CoreUI` | Colours, typography, spacing, view helpers, orientation support |
| `Setup` | The setup screen |
| `Clock` | The clock screen and the game rules |

---

## What the clock does

- Tapping the **active** player's half ends their turn and starts the opponent's.
- **Black presses to start White's clock** — the physical chess clock convention. From not started,
  only a tap on Black's half begins the game, so that half shows `PRESS TO START`.
- The increment goes to the player **who just moved**, never the one about to move.
- `PAUSE` stops the clock behind a full-screen dialog; `RESUME` is the only way out of it.
- `RESET` returns both clocks to full time, asking first if a game is running.
- Below ten seconds — or a tenth of base time in very short games — the running half pulses red.
- A clock reaching zero **flags**: the game ends, the opponent wins on time, and the losing card
  fills accent and reads `FLAG FELL`. Nothing navigates away; `RESET` starts the next game.

---

## Rules in force

- **Time reads in whole seconds**, truncating towards zero — `1:30:00 · 59:59 · 3:07 · 0:00`. Never
  rounds up, because showing a player time they do not have is the one error a clock must not make.
  One implementation, in `Core`.
- **Elapsed real time is the source of truth.** Remaining time is computed from a monotonic instant,
  never accumulated tick by tick, so a 90 minute game does not drift and backgrounding cannot cheat.
- **Portrait everywhere except the clock screen.** A screen declares landscape with one `CoreUI`
  modifier and never names a window scene or an orientation mask.
- **The clock screen carries a custom header** and hides the system bar; back-swipe is off there, so
  a stray swipe cannot abandon a game. Every other screen uses native navigation.
- **No sound. No haptics.** The device lies flat between the players, and a buzz on every switch
  would shift it.
- **Nothing persists.** Every launch starts on Bullet `1 | 0`.
- Colours are colorsets, so dark mode later does not mean touching every screen.
- The Classical preset is `90 | 30` base-plus-increment, **not** the standard two-stage Classical
  format, and its copy says so.

---

## Where to read next

Each module's `Docs/` folder specifies its behaviour in detail — start with `Setup/Docs/` and
`Clock/Docs/`.
