# Architecture

This project layers a screen as **View → Presenter → Service**, with navigation entering and leaving
through a routing protocol the app target implements.

Each layer talks only to the layer directly below it, and every cross-layer dependency that *can* be
a protocol is one. Each layer owns its own models and maps at the boundary — a view never sees a
domain type.

**Single source of truth** is the principle underneath all of it. State lives in exactly one place
and flows upward. The Presenter trusts its Service entirely; the View trusts its Presenter entirely.
No layer reaches sideways for an alternative copy of the same state.

---

## Layer Overview

```
View  ──▶  Presenter  ──▶  Service  ──▶  injected seam (e.g. a time source)
              │
              └──▶  Routing protocol  ──▶  the app's router
```

That is the whole chain today. There is deliberately **no UseCase, Repository, DataSource or
Client** anywhere in this project, because there is no data to fetch: the app is a chess clock with
no network, no database and no persistence. Inventing those layers to hold nothing would be
ceremony.

---

## Dependency Injection

All dependencies are injected through the constructor. No layer creates its own dependencies
internally, and every injected dependency is expressed as a **protocol**, never a concrete type.

```swift
public final class ClockPresenter {

    private let gameService: GameServiceProtocol
    private let router: ClockRoutingProtocol

    public init(gameConfiguration: GameConfiguration, gameService: GameServiceProtocol, router: ClockRoutingProtocol) { ... }

}

public final class GameService: GameServiceProtocol {

    private let timeSource: TimeSourceProtocol

    public init(timeControl: TimeControl, timeSource: TimeSourceProtocol) { ... }

}
```

The chain is assembled in one place — `Dependencies` in the app target, the composition root. It is
the only thing that names concrete types.

### Exception: the View holds its Presenter concretely

A View's Presenter is the one dependency that is **not** behind a protocol:

```swift
public struct ClockView: View {

    @State private var presenter: ClockPresenter

    public init(presenter: ClockPresenter) { ... }

}
```

This is a constraint, not a preference. Presenters are `@Observable`, and observation is delivered
through `@State` holding the concrete type. A presenter behind an existential protocol would not
drive the view — the screen would simply stop updating. So the type is concrete, while the
dependency is still **injected** rather than constructed: the view never builds its own presenter,
and whoever routes to the screen decides what it is showing.

Testing does not suffer for it, because the Presenter's own dependencies are all protocols. A test
substitutes the Service and the router and drives the real Presenter.

### Exception: services UIKit owns the lifetime of

A small number of shared services cannot be injected, because nothing in the app constructs the
object that reads them. `OrientationService` in `CoreUI` is the standing example: it is reached as
`OrientationService.shared` from both the app delegate and the view modifier that drives it.

The reason is structural rather than convenient. `UIApplicationDelegate` is instantiated by UIKit,
so it cannot be handed dependencies, and the modifier has to reach *the same instance the delegate
reads* or the two disagree about what the app supports. There is no seam to inject through.

The exception is about **lifetime, not coupling**. Such a service is still declared behind a
protocol (`OrientationServiceProtocol`), still exposes intent-named methods, and its `shared` is
still typed as the protocol rather than the concrete class. What is given up is the ability to
substitute it per call site — nothing else.

This does not generalise. A shared instance is permitted only where the consumer is constructed by
the system and cannot be reached any other way.

---

## Presentation Layer

### View

- Each View has exactly one Presenter. No exceptions.
- Views are passive — they render state the Presenter gives them and report interactions back.
- Views never talk to Services directly.

### View Model & Action

- Every view that receives data defines its own `Model` as a nested struct in an extension.
- Every view that produces interactions defines its own `Action` as a nested enum in an extension.
- The Presenter constructs the `Model` with everything the view needs to render.
- **The View never sees a domain type.** Where a view needs an identity, it declares its own
  presentational enum rather than accepting the domain one.

```swift
struct ClockFace: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View { ... }

}

extension ClockFace {

    struct Model {

        let side: Side
        let name: String
        let time: String
        let state: State

    }

}

extension ClockFace {

    enum Action {

        case press(Side)

    }

}
```

The parent switches over a child's `Action` in a private extension and calls the presenter:

```swift
private extension ClockView {

    func onClockFaceAction(_ action: ClockFace.Action) {
        switch action {
        case let .press(side): presenter.press(side)
        }
    }

}
```

### Presenter

- `@Observable`, and holds no stored UI state it can compute instead — the models it exposes are
  computed from the Service's state, so there is one copy of the truth.
- Maps domain state into view models, and turns view actions into calls on a Service or the router.
- Named `ScreenNamePresenter`, and lives beside its view.

```swift
var whiteClock: ClockFace.Model {
    makeClockModel(for: .white)
}
```

Localization belongs to the **view**, not the presenter: the `Model` carries the parameters a string
needs, and the view builds the copy. A presenter that returns a finished sentence has become a
string factory, and the format string stops being whole for a translator.

---

## Domain Layer

### Service

Anything that **holds state or owns rules** is a Service. It lives in `Sources/<Module>/Services/`.

- Implements a protocol (`GameServiceProtocol`) — only the protocol is visible to the Presenter.
- Owns the feature's state and the rules that mutate it. `GameService` owns the two clocks, whose
  turn it is, and what starting, ending a turn, pausing and resetting mean.
- Exposes state as a value the Presenter reads, and intent-named methods that change it.
- Takes its own dependencies — the seams that make it testable — through the constructor.

**They are Services, not UseCases.** A UseCase is a stateless operation; these components keep state
for the life of a screen, and calling one a UseCase would misdescribe it. One Service per coherent
piece of domain behaviour — do not create fat services spanning unrelated features.

### Seams

Where a Service depends on something the test needs to control — the clock, the calendar, a random
source — that dependency goes behind a small protocol and is injected:

```swift
public protocol TimeSourceProtocol {

    var now: ContinuousClock.Instant { get }

}
```

This is what lets a 90 minute game be played out in milliseconds instead of in real time, and it is
the reason the clock's correctness is testable at all.

---

## Navigation

A feature does not know where it sits in the app. It declares **what it needs to be able to do**,
and something above it obliges.

- Each module owns a routing protocol in `Sources/Common/Navigation/` — `SetupRoutingProtocol`,
  `ClockRoutingProtocol`. It is the one file in a feature the app target must know about.
- The protocol belongs to the **module**, not to a screen: it says how the app enters and leaves the
  feature, and it serves every screen the module grows.
- The Presenter takes it through the constructor, like any other dependency.
- The app target owns a single `@Observable` router holding the navigation path, and conforms to
  each feature's routing protocol in its own extension.
- Destinations are cases on one `NavigationDestination` enum, carrying whatever the destination
  needs to be built.

Feature modules therefore never import each other, and a feature can be presented from anywhere that
can satisfy its protocol.

---

## Rules

- Every cross-layer dependency goes through a protocol, with one exception: a View holds its
  Presenter concretely, because `@Observable` requires it.
- All dependencies are injected through the constructor. The only components that construct their
  own are the composition root and services whose consumer UIKit owns — see the two exceptions above.
- Never skip layers. A View does not talk to a Service.
- Never leak a domain model into a View's `Model` or `Action`.
- Single source of truth at every layer. A Presenter computes from the Service's state rather than
  keeping its own copy.
- One Presenter per View. Do not share Presenters between Views.
- State-holding components are Services in `Services/`, not UseCases.
- Feature modules never import each other. Communication goes through a protocol the app satisfies.
- Do not add layers for data the app does not have.
