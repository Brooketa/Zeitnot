# Setup Screen

The launch screen, in portrait. The player picks the ruleset the game will be played under and
starts the game from here.

This document is the source of truth for how the screen behaves. Sections marked **Not built yet**
describe intent only.

---

## Ruleset Cell

One row representing a single ruleset. Used for every preset, and in an adapted form for the custom
ruleset.

### What it shows

Leading side, top to bottom:

- **Category** — small uppercase red type (`BULLET`, `BLITZ`, `RAPID`, `CLASSICAL`, `CUSTOM`). The
  cell uppercases it for display; it is supplied in natural casing so it is spoken as a word.
- **Time control** — large bold type, read as `1 | 0`.
- **Description** — grey body copy.

Trailing side, vertically centred, is the **selection control**:

- Unselected — an empty grey ring.
- Selected — a filled red circle with a white check.

### How it behaves

- **The whole row is the tap target**, not just the selection control. Tapping anywhere in the row
  asks for that ruleset to be selected.
- The cell renders selection; it does not decide it. It reports the tap and re-renders from whatever
  state it is handed.
- The cell knows nothing about its position in the list. First and last cells are tucked into the
  card's rounded corners because the card clips them, not because the cell adapts.
- **Long descriptions wrap** onto as many lines as they need and are never truncated. The row grows
  to fit; neighbouring rows are unaffected.

### Type sizing

Type is deliberately **fixed** and does not respond to Dynamic Type — the design tokens set explicit
point sizes on purpose. Robustness therefore means the layout absorbs longer content: descriptions
wrap, rows grow vertically, and nothing truncates or clips.

The cell has **no VoiceOver support**, by decision rather than oversight. It reads as whatever
SwiftUI produces by default. See ZN-59.

---

## Preset Rulesets

The six options the player picks from, in this display order. The catalogue is an enum, so the order
is the declaration order and there is no separate list to keep in sync.

| Category | Time control | Description |
|---|---|---|
| BULLET | 1 \| 0 | One minute each. Sudden death. |
| BLITZ | 3 \| 2 | Three minutes, plus 2s on every completed move. |
| BLITZ | 5 \| 0 | Five minutes each — the classic blitz game. |
| RAPID | 10 \| 0 | Ten minutes each, no increment. |
| RAPID | 15 \| 10 | Fifteen minutes, plus 10s per move. |
| CLASSICAL | 90 \| 30 | 90 minutes each, plus 30s per move. |

**Blitz `3 | 2` is what a first launch with nothing stored shows as selected.** That default is not
expressed in the catalogue — which option starts selected is screen behaviour, so it belongs with
whatever resolves a stored selection to a shown one (the Presenter, or the repository reading
storage once ZN-20 exists). The catalogue lists the six and says nothing about which one wins.

**Presets are not editable.** No code enforces this: an enum case has no setter, so the guarantee is
structural. Only the custom ruleset is editable, and it is a separate thing entirely.

A preset exposes exactly what its consumers need — `category`, `timeControl` and `description`.
Category is a plain string, because nothing branches on it: its only use is the label at the top of
a cell. There is no wrapping ruleset type either — the cell is handed display strings by its
Presenter, and a started game is handed a `TimeControl`.

`TimeControl` is the only real model here. Everything else a preset carries is display copy.

Each preset carries a **stable storage key** (`"blitz-3-2"`) that is deliberately not derived from
its time control values. ZN-20 persists the key, so changing a preset's values in a later release
cannot orphan a saved selection — which matters, because Classical's copy has already been revised
once and ZN-53 will change its values again.

### On the Classical preset

Its copy reads "90 minutes each, plus 30s per move", which is **not** the standard Classical format.
The real thing adds 30 minutes after move 40, and multi-stage time controls are deferred to ZN-53.
The copy was rewritten so the app does not describe behaviour it does not have.

---

## Card Container

Sections of the screen sit in a card: a surface-coloured rounded rectangle that **clips its
contents**. Rows placed inside it are separated by full-bleed hairline dividers, and the first and
last rows are tucked into the rounded corners by the clip.

The card takes arbitrary content rather than a list of rulesets, because the screen's other sections
(custom configuration, preferences) are not rows of rulesets.

---

## Not Built Yet

- The `PRESET RULESETS` list rendering and its heading (ZN-21) — the catalogue exists, but nothing
  displays it yet
- Which ruleset is selected, and that exactly one is selected at all times (ZN-17)
- The `CUSTOM` section and its steppers (ZN-18)
- The `PREFERENCES` section and the sound preference (ZN-19)
- Selection, custom values and preferences surviving a relaunch (ZN-20)
- The sticky `START GAME` bar and navigation to the clock (ZN-21, ZN-22)
- VoiceOver support for this screen's controls (ZN-59)

---

## Acceptance Checklist

### Ruleset cell

- [x] Shows category, time control and description on the leading side, selection control on the
      trailing side.
- [x] Unselected state is an empty grey ring; selected state is a filled red circle with a white
      check.
- [x] Tapping anywhere in the row — not only the control — reports a selection.
- [x] Long descriptions wrap rather than truncate, and the row grows to fit.

### Preset rulesets

- [x] All six presets exist with exactly the copy and order above.
- [ ] Blitz `3 | 2` is the selection on a first launch with nothing stored — **not the catalogue's
      job**; decided where the selection is resolved (ZN-17 / ZN-20).
- [x] Presets are not editable by the player.

### Card container

- [x] Cells sit inside a rounded surface card that clips them.
- [x] Cells are separated by dividers.
- [x] First and last cells are tucked into the card's rounded corners.
