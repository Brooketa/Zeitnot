# CoreUI

Shared SwiftUI building blocks — design tokens, view helpers, and orientation support. Depends on
`Core` and nothing else.

Feature-specific UI does not belong here, and neither does business logic or state. A component
earns its place once a second module needs it.

---

## Design Tokens

| Family | What it holds |
|---|---|
| **Colours** | `ColorPalette` — background, surface, ink, accent, separators, control borders. Colorsets, so dark mode later does not mean touching every screen. |
| **Typography** | `Typography` — a named style per role, each fixing size, weight, tracking and colour. Applied through `Text` helpers. |
| **Spacing** | `CGFloat` constants — `extraSmall` 4 through `jumbo` 24, plus `grid(_:)` for multiples of 4. |

Type sizes are **explicit points and do not scale.** Layout robustness means content wraps and rows
grow, not that the type resizes.

Two typography styles exist for the clock alone: `clockDigits`, monospaced so digits do not shift as
they count, and `playerName`, small and widely tracked.

---

## View Helpers

Sizing, alignment, background and a few conveniences, applied as modifiers.

**They replace `Spacer`.** Rather than pushing content around with an invisible sibling, expand the
element that should take the room and give it an alignment:

```swift
HStack {
    label
        .alignLeading()

    icon
}
```

A `Spacer` states the layout as a side effect — the reader has to work out which neighbour it pushes
and in which direction. Expanding the element that actually claims the space says it directly and
survives reordering.

**The alignment set is complete on purpose.** Every edge, corner and axis exists, including variants
nothing calls yet, so a developer can guess the name without checking which ones happen to be needed.
A partly-populated set is worse than none, because the gaps get filled one-off per screen.

---

## Presenting Over a Screen

`presentFullScreen(if:)` overlays a blurred, dimmed scrim and the given view over whatever it is
applied to, fading rather than sliding. The scrim reaches every physical edge; the presented content
stays inside the safe area.

Because it presents *inside* the view, a screen that wants it to cover its chrome has to apply it
outermost and hide the system bar — which is what the clock screen does.

---

## Orientation

The app is portrait throughout except the clock screen. SwiftUI has no way to state that per screen,
so `CoreUI` provides one:

```swift
ClockView(presenter: presenter)
    .supportsLandscape()
```

That is the only orientation word any feature module writes. No screen names a window scene, an
orientation mask, or the app delegate.

### Why it takes three pieces

iOS answers "what orientations does this app support?" by **asking the app delegate** once, then
caching the answer. Nothing observes app state, so flipping a flag in memory does nothing on its own.

- **The service** holds whether landscape is enabled and reports the mask that follows.
- **The app delegate** implements the supported-orientations callback by returning what the service
  reports. It holds no state and makes no decision.
- **The modifier** enables landscape on appear and disables it on disappear.

### The flag and the refresh are one operation

Making the system re-read its answer takes two further calls — invalidating the cached answer, and
asking the active window scene to update its geometry. Both live **inside** the service's enable and
disable methods, not at the call site.

If a caller had to set the flag and then separately prompt the refresh, the two could be written
apart, and the state where the service reports landscape while the screen sits in portrait would be
reachable — a bug that looks correct in a debugger and is wrong on the device. Folding them together
makes that unreachable, and is why the modifier needs no UIKit at all.

The cost, recorded honestly: the service both answers a question and performs a side effect, and it
touches `UIApplication.shared`, so it cannot be exercised in isolation. At the iOS level the two
genuinely are one operation.

### Other things worth knowing

- **The service is a shared instance**, not injected — the app delegate is built by UIKit and cannot
  be handed dependencies, and the modifier must reach the same instance it reads. It stays behind a
  protocol, so the exception is about lifetime, not coupling. The architecture rules record it.
- **It needs an active scene.** The refresh asks the *active* window scene, so a screen applying the
  modifier before any scene is foreground-active stays as it launched. Every landscape screen is
  pushed onto a running app, so the app cannot reach that case.
- **iPad allows everything.** The lock is iPhone-only — an iPad is used however it is held. A product
  decision, not a technical one.
- **The build settings do not decide.** The target permits portrait and both landscapes on iPhone, so
  the delegate is what decides. Upside-down is never returned.
