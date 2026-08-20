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
- **Title** — `Set the clocks`, carried by the navigation bar as its **large title**. It is the system's
  title, not a custom one, so it collapses into the inline bar title on scroll for free. The
  navigation container itself belongs to the app, not to this screen — the screen only names its
  title, which is what lets a pushed screen carry its own.
- **Subtitle** — `Choose a ruleset.`, the first thing in the scrolling content,
  directly beneath the title.
- **Sections** — each one a section header above a card.

Every word on the screen is **held in the module's String Catalog** — see Copy And Localisation.
Nothing user-facing remains as a Swift literal.

**Everything below the navigation bar scrolls as one list**, subtitle included, so the copy moves out
of the way as the player works down the list. Content is full width with the same margins on every
device, from the smallest supported iPhone up to iPad.

### Section header

The small, letter-spaced, uppercase label that introduces a section's card. It is a single reusable
component. It has one caller today; it stays a component because `CUSTOM` (ZN-18) and `PREFERENCES`
(ZN-19) reuse it if they are ever built.

Like the cell's category, the title is **supplied in natural casing** (`Preset Rulesets`) and
uppercased for display, so it is spoken as words rather than letters.

### Sections that exist

Only **PRESET RULESETS**. `CUSTOM` and `PREFERENCES` are **deferred** (ZN-18, ZN-19) and no empty
header stands in for them — a section appears when it has something to show. The START GAME bar is
pinned below.

### Appearance

The app runs in the **light appearance** regardless of the device setting, pinned once at the root.
The colour palette has light values only, so in dark mode the screen's own colours held while
system-drawn chrome — the navigation title above all — flipped to white against them. Dark mode is a
deliberate later pass; until the palette carries dark values, the app asks for light.

### Orientation

The screen is portrait on iPhone, and stays portrait because it does not ask for anything else.

Since ZN-68 the app is no longer portrait-only at the target level: the build settings permit
landscape, and an app delegate answers the system with whatever the orientation service currently
reports. A screen opts into landscape with a single modifier, and this screen does not apply it — so
the answer stays portrait for as long as it is on screen.

The clock screen is the only screen that does apply it (ZN-66), and leaving it puts the app back to
portrait. iPad allows every orientation on every screen, this one included, by decision rather than
omission.

---

## Ruleset Cell

One row representing a single ruleset. Used for every preset. The custom ruleset it was also
designed to serve is deferred (ZN-18), so today it renders the six presets only.

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
SwiftUI produces by default. This is tracked nowhere — see the Deferred section.

---

## Preset Rulesets

The six options the player picks from, in this display order. The catalogue is **one list of values**,
so a preset is a single entry stating its id, category, time control and description together, and
the list's order is the display order.

It was an enum with a switch per property until 2026-08-20. Adding a preset then meant three edits in
three switches, and a missed one compiled cleanly — the same shape as the clock face's five parallel
switches, fixed the same way.

| Category | Time control | Description |
|---|---|---|
| BULLET | 1 \| 0 | One minute each. Sudden death. |
| BLITZ | 3 \| 2 | Three minutes, plus 2s per move. |
| BLITZ | 5 \| 0 | Five minutes each, classic blitz game. |
| RAPID | 10 \| 0 | Ten minutes each, no increment. |
| RAPID | 15 \| 10 | Fifteen minutes, plus 10s per move. |
| CLASSICAL | 90 \| 30 | 90 minutes each, plus 30s per move. |

**Bullet `1 | 0` is what a first launch with nothing stored shows as selected.** That default is not
expressed in the catalogue — which option starts selected is screen behaviour, so it belongs with
whatever resolves a stored selection to a shown one (the Presenter, or the repository reading
storage once ZN-20 exists). The catalogue lists the six and says nothing about which one wins.

**Presets are not editable.** No code enforces this: an enum case has no setter, so the guarantee is
structural. Only the custom ruleset is editable, and it is a separate thing entirely.

A preset exposes exactly what its consumers need — `category`, `timeControl` and `description`.
Category and description are **catalog resources**, because nothing branches on them: their only use
is as labels in a cell. There is no wrapping ruleset type either — the cell is handed display copy by
its Presenter, and a started game is handed a `TimeControl`.

`TimeControl` is the only real model here. Everything else a preset carries is display copy.

Two consumers need the category as **resolved text** rather than as a resource: the START GAME
subtitle, which formats it into a wider catalog entry, and the game configuration, which carries it
to the clock screen. Both are built by the Presenter, so that is where the resource is resolved —
the view never sees an unresolved one, and the domain never sees a resource at all.

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

Exactly one preset is selected at all times. The Presenter holds a single `PresetRuleset` — one entry
of the catalogue, a value carrying an id, a category, a description and a time control — so three of
the rules are structural rather than coded:

- selecting one **deselects the others** — there is nothing else holding a selection,
- **exactly one is always selected** — the property cannot be empty,
- tapping the **already-selected** one is a no-op — assigning the same value changes nothing.

**Bullet `1 | 0` is selected on launch.** The Presenter decides this, not the catalogue.

### How a row is identified

A row is identified by its **id** — the same string that is its storage key, `"blitz-3-2"`. The cell
is given what it renders (category, description, the two numbers behind `3 | 2`, and whether it is
selected) and nothing else; a tap reports `select(id:)`, and the Presenter finds that entry in the
catalogue.

This is a **change from the earlier design**, which handed the whole preset back so no lookup could
fail. What that cost was a view carrying the catalogue type and reaching through it — the cell had to
know that a preset *has* a time control in order to draw one. The trade is deliberate: a lookup that
cannot fail in practice, in exchange for a cell that knows only what it draws.

The id therefore does double duty as the row identity and the persistence key (ZN-20), rather than
being confined to the storage boundary.

When the custom ruleset joins the group (ZN-18), it becomes another entry with its own id — its
category, description and time control are built at runtime rather than listed, which the catalogue
already allows because an entry is a value rather than a case.

The `3 | 2` reading comes from the module's String Catalog, under the key `timeControlNotation`,
which takes the two numbers as arguments. **No call site writes the format** — the cell renders
`Text(.timeControlNotation(base, increment))` and nothing else in the module contains a `|`.

The bar's subtitle is a **separate key**, `selectedRuleset`, taking the category and both numbers
(`Blitz 3 | 2`). It is one phrase rather than a category glued to a notation, which is what lets a
translation reorder it — a composed string could only ever put the category first. It also means no
layer assembles display text: the Presenter hands the bar a category and a time control, and the
view resolves the key.

---

## Copy And Localisation

The module owns a String Catalog at `Sources/Common/Resources/Localization/Localizable.xcstrings`,
a sibling of `Sources/Setup/` rather than a folder inside it, so localisation sits alongside the
module's code rather than within it. The package's default localisation is English.

Because `Common/` is beside the code rather than under it, **the target's root is `Sources/`** and the
resource declaration names the containing folder:

    path: "Sources",
    resources: [.process("Common/Resources/Localization")]

The raised root is what makes the folder-level declaration work: a resource path that reaches
*outside* the target root has its files copied into the bundle verbatim instead of being compiled,
which produces no generated symbols and a `codesign` failure about an unrecognised bundle format —
never a diagnostic naming the catalog. Keeping `Common/` within the root avoids that entirely, and
another catalog dropped into `Localization/` needs no manifest change.

Keys are **named** (`setTheClocks`, `chooseARuleset`, `timeControlNotation`) rather than being the
English text itself. That is what lets Xcode generate a typed symbol per key, so the screen reads
`Text(.chooseARuleset)` and `Text(.timeControlNotation(base, increment))` instead of repeating
literals. Two things follow from it:

- **The English text lives only in the catalog.** A call site names a key and nothing else, so no
  string can be edited in one place and silently diverge from another.
- **A missing key is a compile error**, not a silent fallback to the key text. With the format as
  the key, a typo would have rendered plausible-looking English and hidden itself.

**A key is not always its own symbol.** The generator capitalises the letter following a digit, so
`bullet1plus0Description` produces `.bullet1Plus0Description` and a call site naming the key verbatim
does not compile. The keys here are written in the form the generator emits, so the two read the
same; anything added later that mixes digits and letters needs the same care.

The catalog belongs to this module rather than to the app so the symbols are visible here — Xcode
generates them per target, and a catalog in the app target produces symbols the packages cannot see.

The consequence to know about: **the clock module will not be able to use
`timeControlNotation`.** It renders the same `3 | 2` in its navigation title, and per-module symbols
mean it needs its own key. Whether the two share one entry somewhere both can reach, or simply carry
one each, is a question for ZN-60.

---

## Card Container

Sections of the screen sit in a card: a surface-coloured rounded rectangle that **clips its
contents**. Rows placed inside it are separated by full-bleed hairline dividers, and the first and
last rows are tucked into the rounded corners by the clip.

The card takes arbitrary content rather than a list of rulesets, because the screen's other sections
(custom configuration, preferences) are not rows of rulesets.

---

## Start Game Bar

Pinned to the bottom of the screen, below the scrolling content: a full-width red **capsule** button
reading `START GAME`, the selected ruleset named beneath it (`Blitz 3 | 2`), and a circular arrow on
the trailing side.

### How it behaves

- **The bar stays put while the content scrolls behind it.** It is attached as a bottom safe-area
  inset, which both pins it and pushes the scroll content's own bottom inset down — so the last
  ruleset can be scrolled clear of the bar instead of living underneath it. One mechanism does both
  jobs; there is no hand-maintained bottom padding that has to match the bar's height.
- **Content passing beneath fades out rather than sliding under the button cleanly.** The bar paints
  a gradient behind itself — clear at the top, the screen's background colour at the bottom — so a
  row scrolling past dissolves into the background instead of being cut off by a hard edge.

  This is deliberately *not* the system's scroll edge effect. That effect is what the navigation bar
  uses at the top of this screen and it works there, but at the bottom it had nothing to show:
  scrolled to the end, the content stops above the bar, so there is nothing left underneath to blur.
  A painted gradient reads consistently at every scroll position, which is what the design wants.
- **The subtitle names the current selection and nothing else.** The bar is handed the selected
  ruleset's category and time control, and renders them through one localised key. Both are derived
  from the selection rather than stored, so the subtitle cannot fall out of step with the list —
  including the moment a different preset is tapped, and later when the custom steppers move
  (ZN-18).

### Starting a game

Tapping the bar reports that a game should start, handing out the selected ruleset's **time control
and category**.

The hand-off is a **value taken at the moment of the tap**, not a live reference to the screen's
state. Changing the selection afterwards therefore cannot reach into a game already under way — that
guarantee is structural rather than a rule the clock has to honour.

The screen does not navigate. It reports the intent and whoever presents it decides where that goes,
which is what keeps this module free of any dependency on the clock. Starting a game leaves the
selection untouched, so returning to the screen finds it exactly as it was left.

The seam is in the Presenter rather than in the view's interface. The screen takes no callback and
exposes no hook; a tap is simply a Presenter action, the same as selecting a ruleset. That is what
leaves the routing decision entirely to the layer that makes it.

---

## Navigation

START GAME opens the clock screen, and the module reaches it without knowing it exists.

### What this module names

One protocol, declared here, naming the single navigation this screen can trigger and taking the
game configuration. That is the module's entire vocabulary for navigation: it names no router, no
destination and no other screen, and it does not depend on the clock module.

The Presenter receives that protocol through its initialiser and calls it when the bar is tapped.
Routing is a **Presenter dependency, not a view callback** — the view has no `onStartGame` closure
to hand upwards, so there is no way for a navigation decision to leak into the view layer.

### What the app supplies

The app owns the navigation stack and conforms its router to the protocol, translating the call into
a push carrying the configuration. Because the Presenter is injected with something, the **app
builds the Presenter** and hands it to the screen — so the view's public surface is
`init(presenter:)` rather than `init()`.

The screen holds that Presenter as view state rather than as a plain stored value. Pushing the clock
re-evaluates the app's root body, which re-runs `SetupView`'s initialiser; holding the Presenter as
state means the second initialiser's value is discarded and the original is kept. That is what makes
the selection survive the round trip, and it is a requirement rather than a stylistic choice — a
plain stored Presenter would be rebuilt on the push and the screen would come back reset to Blitz
`3 | 2`.

### Two taps, one clock

A double tap on START GAME opens exactly one clock screen. The guard is the **router's**, not this
module's: the Presenter reports every tap it receives, and the router ignores a push that arrives
while one is already in flight. This screen therefore has no de-duplication logic of its own, and
none should be added here.

### Coming back

Back and back-swipe are the system's, from the system navigation bar. Returning finds the screen
exactly as it was left, because the screen's state lives for the screen's lifetime and starting a
game does not touch it. That lifetime is the session: nothing is stored, so a relaunch is back to
Bullet `1 | 0` (ZN-20).

---

## Deferred

Cut on 2026-08-20, not merely unbuilt. **This screen is finished for this pass** — the six presets,
the cell, selection, the shell and the START GAME bar are all in place, and nothing below is
expected before the app ships.

- The `CUSTOM` section and its steppers (**ZN-18**)
- The `PREFERENCES` section and the sound preference (**ZN-19**) — there is no sound anywhere in the
  app, so there would be nothing for the toggle to govern
- Selection surviving a relaunch (**ZN-20**). Every launch starts on Bullet `1 | 0`

Picking up `CUSTOM` again means revisiting **ZN-64**, which settled row identity on the assumption
that a row is a preset; once a custom ruleset joins the selection group a row becomes a two-case
selection instead. That rework was accepted when ZN-64 was written.

**VoiceOver is not tracked anywhere.** An earlier version of this list named `ZN-59`, which does not
exist and never did. Accessibility criteria were stripped from ZN-16 and ZN-18 rather than met
piecemeal; if it is taken up it should be one Epic covering every screen.

---

## Acceptance Checklist

`[x]` done · `[~]` deferred, and not expected before the app ships — see Deferred. There are no
open `[ ]` items: this screen is finished for this pass.

### Screen shell

- [x] Background, subtitle and the `PRESET RULESETS` section header match the design.
- [x] No user-facing string remains a Swift literal anywhere in the module.
- [x] `Set the clocks` is the navigation bar's large title, not a custom one, with the navigation
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
- [x] Every category and description is a String Catalog entry, not a literal.
- [x] Bullet `1 | 0` is the selection on launch. Decided by the Presenter, not the catalogue.
      Surviving a relaunch with something stored is still ZN-20.
- [x] Presets are not editable by the player.

### Selection

- [x] Selecting a ruleset deselects all others.
- [x] Exactly one ruleset is selected at all times.
- [x] Tapping the already-selected ruleset is a no-op, not a deselect.
- [x] The START GAME subtitle updates immediately on selection.
- [~] The custom ruleset participates in the selection group — **deferred** (ZN-18). Selection spans
      the six presets only, and that is the shipped behaviour, not a gap.

### Card container

- [x] Cells sit inside a rounded surface card that clips them.
- [x] Cells are separated by dividers.
- [x] First and last cells are tucked into the card's rounded corners.

### Start game bar

- [x] The bar is pinned to the bottom and always visible.
- [x] The scrolling content carries enough bottom inset that the last ruleset clears the bar.
- [x] Content passing beneath the bar fades into the background under a gradient.
- [x] The subtitle names the current selection and updates immediately when it changes.
- [x] START GAME opens the clock screen with the selected ruleset's base time and increment.
- [x] The configuration is a snapshot taken at the tap, so a later selection change cannot alter a
      game already under way.
- [x] Returning from the clock preserves the selection.
- [~] Starting a game with the custom ruleset uses the current custom values — **deferred**; the
      custom ruleset does not exist (ZN-18).

### Navigation

- [x] The module declares one routing protocol and names no router, no destination and no other
      screen. It does not depend on the clock module.
- [x] Routing is a Presenter dependency injected through its initialiser, not a view callback.
- [x] The view is constructed with its Presenter and holds it as state, so a push does not rebuild
      it and the selection survives the round trip.
- [x] Two rapid taps on START GAME open exactly one clock screen. The guard belongs to the router;
      this module reports every tap.
- [x] Back and back-swipe are the system's, and return to the screen as it was left.
