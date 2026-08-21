# Setup Screen

The launch screen. The player picks a time control and starts a game. Portrait, native navigation.
This document describes what the screen does today.

---

## Layout

```
Chess Clock
Choose how long you both want to play.

PRESET RULESETS
┌────────────────────────────────────┐
│ BULLET                             │
│ 1 | 0                          ( ) │
│ One minute each. Sudden death.     │
├────────────────────────────────────┤
│ …five more                         │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  START GAME                    (→) │
│  Bullet 1 | 0                      │
└────────────────────────────────────┘
```

Title, subtitle and the list scroll as one. The START GAME bar is pinned.

---

## Preset rulesets

Six options, in display order. The catalogue is **one list of values** — each entry states its id,
category, time control and description together, and the list's order is the display order.

| Category | Time control | Description |
|---|---|---|
| BULLET | 1 \| 0 | One minute each. Sudden death. |
| BLITZ | 3 \| 2 | Three minutes, plus 2s per move. |
| BLITZ | 5 \| 0 | Five minutes each, classic blitz game. |
| RAPID | 10 \| 0 | Ten minutes each, no increment. |
| RAPID | 15 \| 10 | Fifteen minutes, plus 10s per move. |
| CLASSICAL | 90 \| 30 | 90 minutes each, plus 30s per move. |

- **Presets are not editable.** They are immutable values; the guarantee is structural, not enforced.
- Each carries a **stable id** (`"blitz-3-2"`) that is deliberately not derived from its numbers, so
  changing a preset's values cannot orphan anything that stored the id.
- A preset exposes only what its consumers need — category, time control, description. The time
  control is the only real model; the rest is display copy.
- **Classical's copy is accurate to what the app does**, which is base time plus increment. That is
  not the standard two-stage Classical format, and the copy does not claim to be.

---

## Selection

Exactly one preset is selected at all times. The Presenter holds a single preset value, which makes
three rules structural rather than coded:

- selecting one **deselects the others** — nothing else holds a selection,
- **one is always selected** — the property cannot be empty,
- tapping the **already-selected** one does nothing — assigning the same value changes nothing.

**Bullet `1 | 0` is selected on launch.** The Presenter decides that, not the catalogue.

A row is identified by its **id**. The cell is handed what it renders — category, description, the
two numbers behind `1 | 0`, and whether it is selected — and nothing else. A tap reports the id back,
and the Presenter resolves it to a preset.

---

## Ruleset cell

Category in small uppercase accent, the time control large and bold, the description in grey beneath.
A selection indicator sits on the trailing side: an empty grey ring, or a filled accent circle with a
check.

- **The whole row is the tap target**, not just the indicator.
- Long descriptions wrap and the row grows. Type does not scale — the design tokens set explicit
  point sizes.
- Cells sit in a shared card with dividers between them, the first and last tucked into the card's
  rounded corners.

---

## Start game bar

A full-width accent capsule reading `START GAME`, the selected ruleset named beneath it
(`Bullet 1 | 0`), and a circular arrow trailing.

- **It stays put while content scrolls behind it.** Attached as a bottom safe-area inset, which pins
  it *and* pushes the scroll content's own inset down — so the last row can be scrolled clear rather
  than living under the bar. One mechanism, no hand-maintained padding to keep in step.
- **Content fades as it passes beneath.** The bar paints its own gradient — clear at the top, the
  screen background at the bottom. The system scroll edge effect is not used here: scrolled to the
  end there is nothing left underneath to blur, so it would show nothing.
- **The subtitle is derived from the selection**, not stored, so it cannot fall out of step with the
  list — including the moment a different preset is tapped.

---

## Starting a game

Tapping the bar hands out the selected ruleset's **time control and category** as a value taken at
the moment of the tap. Changing the selection afterwards therefore cannot reach a game already under
way — structural, not a rule the clock has to honour.

**The screen does not navigate.** It reports the intent through the module's routing protocol and
whoever presents it decides where that goes, which is what keeps this module free of any dependency
on the clock.

Starting a game leaves the selection untouched, so returning finds the screen exactly as it was.

---

## Localization

Every user-facing string resolves from the module's String Catalog through a generated symbol. Copy
is stored in **natural casing** and views uppercase for display, so it is still spoken as words.

The time control notation (`1 | 0`) and the bar's subtitle are single phrase keys taking the numbers
as parameters, rather than strings concatenated in the Presenter — so a translation can reorder them.
