# CoreUI (Android)

The design tokens the Android screens are built from — colours, typography and spacing. It depends on
Compose and nothing else, knows nothing about the game, and holds no strings.

It is the Compose restatement of the iOS `CoreUI` module. The design is one design; only the language
differs. **Every token carries the same name on both platforms**, so a change made on one is findable
on the other by searching for the name.

---

## Colours

Fourteen names, transcribed from the iOS colorsets.

| Group | Names |
|---|---|
| Surfaces | `background` · `surface` · `surfaceMuted` |
| Text | `ink` · `inkInverse` · `textSecondary` · `textTertiary` |
| Accent | `accent` · `accentPressed` · `accentTint` · `accentRaised` |
| Lines | `separator` · `rule` · `controlBorder` |

**No dark variant is declared**, matching iOS today. Nothing about the tokens prevents one later.

---

## Typography

Twelve named roles. Each fixes size, weight, tracking and colour, so a call site picks a role and
never assembles a style.

| Role | Reads as |
|---|---|
| `clockDigits` | The time reading — 76pt, bold, tabular figures |
| `largeTitle` · `title` · `headline` | Headings, descending |
| `body` · `calloutBold` · `callout` · `footnote` | Running text |
| `buttonLabel` | Text on an accent-filled control, so it carries `inkInverse` |
| `label` · `playerName` · `micro` | Small, widely tracked, upper-case in use |

`clockDigits` sets `tnum`, so digits occupy equal width and the reading does not shift as it counts
down. It is a font *feature*, not a monospaced face — the numerals change, the rest of the face does
not, which is what the iOS style does with monospaced digits.

---

## Spacing

Six steps — `extraSmall` 4, `small` 8, `medium` 12, `large` 16, `extraLarge` 20, `jumbo` 24 — plus
`grid(_)` for multiples of four. Layouts name a step; they do not write `dp` inline.

---

## Two Deliberate Differences From iOS

**Sizes are in `sp`, so they follow the reader's font setting.** The iOS styles are fixed points and
do not scale. At the default setting the two render identically; above it, Android type grows and iOS
type does not. Respecting the system font size is the platform's own accessibility contract, and
breaking it to match a screenshot is the wrong trade.

**Material is not used.** `MaterialTheme` supplies its own colours and type scale, and a screen that
reached for both would inherit half its appearance from Material defaults. The tokens here are the
only source, and the app depends on Compose Foundation rather than Material3.
