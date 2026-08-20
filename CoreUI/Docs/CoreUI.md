# CoreUI

The shared UI layer. Everything visual that more than one screen needs lives here — the design
system's tokens, and the vocabulary views are written in. It depends on `Core` and on nothing else.

This document is the source of truth for what CoreUI provides and why.

---

## Design Tokens

Three families, each in its own folder under `Design/`.

- **Colours** — a named palette, backed by an asset catalogue. Screens never name a literal colour;
  they name a role (a background, a surface, an accent, a separator). The palette carries light
  values only. Dark mode is a later pass, and the reason it is survivable is that adding dark values
  to the catalogue changes every screen at once without any screen being touched.
- **Typography** — a fixed set of styles, applied through text helpers so a view says which style it
  wants rather than restating a size, a weight and a tracking. Type is **deliberately fixed** and
  does not respond to Dynamic Type; robustness means layouts absorb longer content instead.
- **Spacing** — a named scale, so padding and stack spacing come from a small vocabulary rather than
  arbitrary numbers.

---

## View Helpers

A set of view extensions covering the layout intent that recurs on every screen: taking the
available width or height, settling into a position within those bounds, applying the app's screen
background, and expressing availability in the positive.

None of them add behaviour. Each is a thin wrapper over a modifier the platform already has, and the
whole value is at the call site: the underlying modifier states *configuration*, and these state
*intent*, which is what someone reading a view body is looking for. A row that fills its width and
aligns its content to the leading edge says so, instead of spelling out an infinite frame and an
alignment argument.

### They replace `Spacer`

Layout is expressed by expanding the element that should take the space and aligning it, never by
placing an invisible sibling to push against. A `Spacer` describes a gap and leaves the reader to
infer what it is pushing and where; an expanded, aligned element says what it is doing. The rule is
recorded in the code style rules; the helpers are what make following it short.

### The set is complete on purpose

The alignment helpers cover every edge, every corner and both axes, including combinations nothing
calls yet. That is deliberate, and it is a **stated exception** to the rule that unused code is
removed — recorded in the code style rules, not left as a thing a reviewer has to infer.

The reasoning: the value of a helper set is that a developer can guess the name without checking
which variants happened to be needed so far. A set with gaps gets those gaps filled one-off, per
screen, in slightly different shapes — which is the duplication the set exists to prevent. The
exemption is scoped to closed, obvious sets in shared modules; it is not a licence for speculative
API anywhere else.

### The background helper reads from the palette

It resolves the screen background through the colour palette rather than naming a colour of its own,
so there is one place a background colour is defined and the dark-mode pass has one place to change.

---

## What Does Not Belong Here

- Business logic or state of any kind. CoreUI is presentation vocabulary; it never decides anything.
- UI used by only one feature. That stays in the feature until a second one needs it, at which point
  it is promoted here.
- Anything a feature module would have to reach *around* — CoreUI is depended upon, never depends
  back.

---

## Acceptance Checklist

- [x] Colour, typography and spacing tokens exist and are the only way screens name those values.
- [x] Colours are backed by an asset catalogue so dark values can be added without touching screens.
- [x] View helpers exist for sizing, alignment, screen background and availability.
- [x] The alignment set is complete, and its exemption from the unused-code rule is written down
      where that rule lives.
- [x] The screen background helper resolves through the colour palette.
