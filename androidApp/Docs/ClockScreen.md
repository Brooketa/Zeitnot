# Clock Screen (Android)

The landscape screen a game is played on. The device lies flat between the players, each tapping
their own card.

---

## Layout

```
‹  ● BULLET · 1 | 0   MOVE 2

  ┌──────────────┐  ┌──────────────┐
  │    WHITE     │  │    BLACK     │
  │    1:00      │  │    1:00      │
  │              │  │PRESS TO START│
  └──────────────┘  └──────────────┘

      DIGITAL | ANALOG   PAUSE   RESET
```

- **Header** — back control, status dot, ruleset, move number.
- **Two equal cards**, White left, Black right, each a full-height tap target.
- **Control bar** — the display-mode control, pause and reset, centred beneath.

---

## Playing

| Status | Card |
|---|---|
| Awaiting start | Muted name and face. Black's card reads `PRESS TO START` |
| To move | Accent name, ink face, accent ring |
| Low time | As to-move, with the ring pulsing |
| Waiting | Muted name and face, no ring |
| Flagged | Fills accent, inverse type, reads `FLAG FELL` |

Only Black's card invites the first press, and only the running card can end a turn — the domain
enforces both, so a tap on the wrong card does nothing.

**The move number counts chess moves**, so it advances when Black presses, not White. The status dot
is accent while a clock counts down and grey otherwise.

**Nothing in Kotlin computes time.** The reading, the status and the low-time threshold all come from
`Shared`; the screen turns them into colour and copy.

---

## Display modes

`DIGITAL` shows the shared reading. `ANALOG` shows a dial whose hands sit behind the 12 by the
remaining time and sweep clockwise as it is spent, so both reach the 12 at zero. Two hands only — a
minute hand on a 60-minute revolution and a second hand on a 60-second one.

Switching is presentation and nothing else: it never pauses, resets or changes whose turn it is, and
it is safe mid-game. Digital is the default, and both cards always show the same mode.

The dial carries a rim, twelve hour ticks and bold numerals, a minute hand with a hub, and a second
hand with a short counterweight tail.

It is **drawn rather than loaded**, because the iOS artwork is a vector PDF that Android cannot read,
and its numerals are live text — which a vector drawable cannot hold either. The geometry is taken
from that artwork rather than approximated: the same rim radius and stroke, the same tick lengths,
the same hand lengths and widths, numerals at the same radius and size. Changing the dial means
changing it in both places.

---

## Pause and reset

Pause stops the running clock behind a full-screen dialog naming the player to move; `RESUME` is the
only way out. Reset asks first while a game is in progress and acts immediately once a game has
finished. Both controls are disabled when they would do nothing.

**A dialog presents over a blurred clock.** The screen behind is blurred and dimmed to 80% of the
background colour, cross-fading over a quarter of a second, so the game stays visible without
competing with the dialog — the same treatment as iOS. The scrim consumes taps, so nothing behind it
can be pressed by accident.

Blurring needs **Android 12 or newer**. On 9 through 11 the dim and the fade still happen and the
clock behind simply stays sharp.

---

## Orientation and leaving

The screen is **landscape**, and Setup is portrait, so each screen states the orientation it wants as
it appears. The activity handles the configuration change itself rather than being recreated — a
rotation must not destroy a running game.

**The system back gesture is disabled here.** A stray swipe would abandon a game with no
confirmation; leaving is the deliberate tap on the back control.

---

## While the app is away

A backgrounded game keeps losing time, because remaining time is measured from a monotonic instant
rather than counted down. The screen stops redrawing when it is not visible and catches up when it
returns; the clock cannot gain time by being hidden.
