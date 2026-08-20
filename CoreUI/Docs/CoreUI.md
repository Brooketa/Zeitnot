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

## Orientation

The app is portrait throughout except the clock screen, which is landscape — the device lies flat
between the two players. SwiftUI has no way to state that per screen, so CoreUI provides one.

A screen declares what it needs with a single modifier and nothing else:

    ClockView(presenter: presenter)
        .supportsLandscape()

That is the only orientation word any feature module ever writes. No screen names a window scene, an
interface orientation mask, or the app delegate.

### Why it takes three pieces

iOS answers "what orientations does this app support?" by **asking the app delegate**, once, when it
decides it needs to know — and then caching the answer. Nothing observes app state. So changing a
flag in memory does nothing on its own: the system already has an answer and no reason to ask again.

- **The service** holds whether landscape is currently enabled and reports the mask that follows. It
  is the single source of truth for the answer.
- **The app delegate**, added to the SwiftUI app through the delegate adaptor, implements the
  supported-orientations callback by returning what the service reports. It holds no state and makes
  no decision — it only forwards the question.
- **The modifier** enables landscape on appear and disables it on disappear.

### The flag and the refresh are one operation

Making the system re-read its answer takes two further calls — invalidating the cached answer on the
root view controller, and asking the active window scene to update its geometry. Both live **inside**
the service's `enableLandscape()` and `disableLandscape()`, not at the call site.

That is deliberate. If a caller had to change the flag and then separately prompt the refresh, the
two could be written apart, and the state where the service reports landscape while the screen sits
in portrait would be reachable — a bug that looks correct in a debugger and is wrong on the device.
Folding the refresh in makes that state unreachable rather than merely discouraged, and it is why the
modifier needs no UIKit at all.

The cost, recorded honestly: the service both answers a question and performs a side effect, and it
touches `UIApplication.shared`, so it cannot be exercised in isolation. At the iOS level the two
genuinely are one operation, and splitting them would move half of it into every caller.

### The service is a shared instance

`OrientationService.shared`, not an injected dependency — a stated exception to the
constructor-injection rule, recorded in the architecture rules where that rule lives. The app
delegate is built by UIKit and cannot be handed dependencies, and the modifier must reach the same
instance the delegate reads. It stays behind `OrientationServiceProtocol`, so the exception is about
lifetime rather than coupling to a concrete type.

### It needs an active scene

The refresh asks the **active** window scene to update its geometry, so a screen that applies the
modifier while no scene is foreground-active yet — the app's launch root — stays in the orientation
it launched in. Every screen that declares landscape is pushed onto a running app, so the app cannot
reach that case; it is recorded because it is why the clock screen was verified by pushing it rather
than by launching into it.

### iPad allows everything

The lock is iPhone-only. An iPad is used in whatever orientation it is held or docked in, and forcing
it into portrait for the setup screen is hostile in a way it is not on a phone; the clock screen reads
correctly either way on a large display. This is a product decision, not a technical one.

### The build settings do not decide

The app target permits portrait and both landscapes on iPhone, so the delegate is the thing that
decides. Upside-down is deliberately absent — the delegate never returns it on a phone.

---

## What Does Not Belong Here

- Business logic. CoreUI is presentation vocabulary; it never decides anything about a game.
- State, with **one** exception: the orientation service holds whether landscape is currently
  enabled. It is here because it must import UIKit and so cannot live in `Core`, and because the
  thing it serves — the modifier — is a view concern. It holds a device capability, not app data.
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
- [x] A screen declares landscape with one modifier and never names a window scene or an
      orientation mask.
- [x] The orientation service is reached through a protocol, and its exemption from constructor
      injection is written down where that rule lives.
- [x] Changing the orientation flag always prompts the system to re-read it, because the two are a
      single call.
- [x] iPhone locks to the declaring screen's orientation; iPad allows all orientations everywhere.
- [x] The app target's supported-orientation build settings permit every orientation the delegate
      may return.
