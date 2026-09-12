# Setup Screen (Android)

The launch screen. The player picks a time control and starts a game. Portrait.

---

## Layout

```
Set the clocks
Choose a ruleset.

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

Title, subtitle and the card scroll together. The start bar is pinned, and paints a gradient from
clear to the screen background so content fades as it passes beneath.

---

## Preset rulesets

Six rows in one card, dividers between, in the order `Shared` lists them. A row shows its category in
small uppercase accent, the time control large, and a description beneath.

**The presets are shared; their words are not.** `Shared` supplies which preset it is — a category
token, two numbers and a stable id. The category names and the six descriptions are Android string
resources, resolved from that id. No time control value or category classification is written in
Kotlin.

Copy is stored in **natural casing** and uppercased for display, so it is still spoken as words.

---

## Selection

Exactly one preset is selected, Bullet `1 | 0` on launch. The presenter holds a single preset, so
selecting one deselects the others, one is always selected, and re-tapping the selected row changes
nothing.

**The whole row is the tap target.** The indicator is an empty grey ring, or a filled accent circle
with a check.

**The selection survives a configuration change.** It is saved as the selected preset's id and the
presenter is restored from it.

---

## Starting a game

The bar names the current selection (`Bullet 1 | 0`), derived from it rather than stored, so it
cannot fall out of step. Tapping hands the selected time control and category to the clock screen as
a value taken at that moment, so changing the selection afterwards cannot reach a game already under
way.

Starting a game leaves the selection untouched.
