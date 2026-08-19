# Setup Screen

The launch screen, in portrait. The player picks the ruleset the game will be played under and
starts the game from here.

This document is the source of truth for how the screen behaves. Sections marked **Not built yet**
describe intent only.

---

## Screen Shell

The frame every section sits in — background, header and section structure.

Top to bottom:

- **Background** — the screen's surface colour behind everything, extending under the status bar and
  the home indicator.
- **Title** — `Chess Clock`, carried by the navigation bar as its **large title**. It is the system's
  title, not a custom one, so it collapses into the inline bar title on scroll for free. The
  navigation container itself belongs to the app, not to this screen — the screen only names its
  title, which is what lets a pushed screen carry its own.
- **Subtitle** — `Choose how long you want to play.`, the first thing in the scrolling content,
  directly beneath the title.
- **Sections** — each one a section header above a card.

**Everything below the navigation bar scrolls as one list**, subtitle included, so the copy moves out
of the way as the player works down the list. Content is full width with the same margins on every
device, from the smallest supported iPhone up to iPad.

### Section header

The small, letter-spaced, uppercase label that introduces a section's card. It is a single reusable
component, built here and reused by every section that follows — `CUSTOM` (ZN-18) and `PREFERENCES`
(ZN-19).

Like the cell's category, the title is **supplied in natural casing** (`Preset Rulesets`) and
uppercased for display, so it is spoken as words rather than letters.

### Sections that exist

Only **PRESET RULESETS**. `CUSTOM` and `PREFERENCES` arrive with their own tickets, and no empty
header stands in for them in the meantime — a section appears when it has something to show. The
screen has no bottom bar yet either, so the content scrolls to its natural end (ZN-22).

### Appearance

The app runs in the **light appearance** regardless of the device setting, pinned once at the root.
The colour palette has light values only, so in dark mode the screen's own colours held while
system-drawn chrome — the navigation title above all — flipped to white against them. Dark mode is a
deliberate later pass; until the palette carries dark values, the app asks for light.

### Orientation

The screen is portrait, and the app is portrait-only on iPhone. The clock screen is the app's one
landscape screen; it re-introduces landscape support together with the per-screen orientation
control it needs (ZN-23). iPad currently still rotates.

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
| BLITZ | 5 \| 0 | Five minutes each, classic blitz game. |
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

## Selection

Exactly one preset is selected at all times. The Presenter holds a single `PresetRuleset`, so three
of the rules are structural rather than coded:

- selecting one **deselects the others** — there is nothing else holding a selection,
- **exactly one is always selected** — the property cannot be empty,
- tapping the **already-selected** one is a no-op — assigning the same value changes nothing.

**Blitz `3 | 2` is selected on launch.** The Presenter decides this, not the catalogue.

### How a row is identified

A row is **the preset plus whether it is selected**, and nothing else. The cell reads its category,
time control and description from the preset directly, because restating them alongside it would be
two representations of one fact. A tap hands the whole row back, so the Presenter reads the preset it
already constructed — there is no lookup that can fail and no unknown-identifier case to handle.

Storage keys stay out of this. `PresetRuleset.rawValue` is used only at the persistence boundary
(ZN-20), not to move a selection between the view and the Presenter.

When the custom ruleset joins the group, the row identity becomes the two-case selection rather than
a preset — the same change, one type wider.

The `3 | 2` reading is built in the cell, from the time control's two numbers — the first place that
format appears in the app. ZN-60 replaces it with a shared String Catalog key, which views reference
directly, so the format stays where it is read.

---

## Card Container

Sections of the screen sit in a card: a surface-coloured rounded rectangle that **clips its
contents**. Rows placed inside it are separated by full-bleed hairline dividers, and the first and
last rows are tucked into the rounded corners by the clip.

The card takes arbitrary content rather than a list of rulesets, because the screen's other sections
(custom configuration, preferences) are not rows of rulesets.

---

## Not Built Yet

- The `CUSTOM` section and its steppers (ZN-18)
- The `PREFERENCES` section and the sound preference (ZN-19)
- Selection, custom values and preferences surviving a relaunch (ZN-20)
- The sticky `START GAME` bar and navigation to the clock (ZN-22)
- VoiceOver support for this screen's controls (ZN-59)

---

## Acceptance Checklist

### Screen shell

- [x] Background, subtitle and the `PRESET RULESETS` section header match the design.
- [x] `Chess Clock` is the navigation bar's large title, not a custom one, with the navigation
      container owned by the app rather than the screen.
- [x] The section header is a reusable component, not styling applied inline once.
- [x] Everything below the navigation bar scrolls as one list, subtitle included.
- [x] The screen is portrait.
- [x] The screen renders in the light appearance with a black title, whatever the device setting.
- [x] The layout holds from the smallest supported iPhone up to iPad.

### Ruleset cell

- [x] Shows category, time control and description on the leading side, selection control on the
      trailing side.
- [x] Unselected state is an empty grey ring; selected state is a filled red circle with a white
      check.
- [x] Tapping anywhere in the row — not only the control — reports a selection.
- [x] Long descriptions wrap rather than truncate, and the row grows to fit.

### Preset rulesets

- [x] All six presets exist with exactly the copy and order above.
- [x] Blitz `3 | 2` is the selection on launch. Decided by the Presenter, not the catalogue.
      Surviving a relaunch with something stored is still ZN-20.
- [x] Presets are not editable by the player.

### Selection

- [x] Selecting a ruleset deselects all others.
- [x] Exactly one ruleset is selected at all times.
- [x] Tapping the already-selected ruleset is a no-op, not a deselect.
- [ ] The START GAME subtitle updates immediately on selection — the bar does not exist yet
      (ZN-22).
- [ ] The custom ruleset participates in the selection group — deferred; selection currently spans
      the six presets only (ZN-18).

### Card container

- [x] Cells sit inside a rounded surface card that clips them.
- [x] Cells are separated by dividers.
- [x] First and last cells are tucked into the card's rounded corners.
