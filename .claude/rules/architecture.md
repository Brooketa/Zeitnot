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

### Where each layer lives

The chain is cut once, between the Presenter and the Service:

```
platform    View  ·  Presenter  ·  its view models  ·  its words  ·  its images
                         │
                         ├──▶  Routing protocol  ──▶  the app's router
                         │
Shared                   └──▶  Service  ──▶  seam
```

**From the Service down is `Shared`**, and every platform runs the same one: the domain, the game
rules, and the snapshot a screen reads. **The whole presentation layer is the platform's** — views,
presenters, view models, routing protocols, String Catalogs and images stay in `Clock`, `Setup` and
`CoreUI`, and Android writes its own in Kotlin.

The line falls there because a presenter is presentation. What two apps must agree about is the game;
what they draw with it is theirs. SwiftUI observes a presenter and Compose reads snapshot state, so a
shared presenter serves neither well, and it drags UI state — a display mode, a dialog flag — across
a language boundary for no reason.

**A rule that decides what is true is domain, wherever it used to live.** When the presenters moved
out, the decisions they were making moved *down* rather than out: the low-time threshold
(`remaining <= min(10s, baseTime / 10)`), the convention that only Black may start, the move number,
and the five-case status of a clock — awaiting start, to move, low time, waiting, flagged. Each has
exactly one home, in `Shared`. A platform maps a status to a colour; it does not decide when a clock
is in trouble.

`Shared` still holds no copy and no SwiftUI, because it must build for Android, where
`LocalizedStringResource` does not exist.

### Both platforms layer the same way

The chain above is the *app's* shape, not Swift's. Android repeats it in Kotlin: a Compose screen
holds a presenter, the presenter holds a service behind an abstraction, and the implementation of
that abstraction is what crosses into `Shared`.

| Concept | iOS | Android |
|---|---|---|
| Abstraction | `GameServiceProtocol` | `GameServiceContract` |
| Implementation | `GameService` | `GameService`, over JNI |
| Observation | `@Observable`, SwiftUI observes | The screen re-reads after an action, and per frame while running |

**An abstraction is suffixed for the language reading it** — `Protocol` in Swift, `Contract` in
Kotlin — so which type is the abstraction stays visible at a glance on both sides.

Compose cannot observe Swift, so Android pulls where iOS is pushed to. That difference is confined to
the presentation layer, which is why it belongs to the platform.

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
- **The View never sees a domain type that carries behaviour or state.** Where a view needs an
  identity, it declares its own presentational enum rather than accepting the domain one —
  `ClockFace.Side` rather than `Player`.

```swift
struct ClockFace: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View { ... }

}

extension ClockFace {

    struct Model {

        let side: Side
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

### A name crosses as a token, and the view names it

Where a view needs to show the name of a domain thing, the `Model` carries the **token** and the view
resolves the name itself:

```swift
struct HeaderModel {

    let category: RulesetCategory

}

Text(.rulesetTitle(String(localized: model.category.name), …))
```

The presenter picks *which* category, the way it picks which number. It does not pick the word: the
token it hands over comes from `Shared`, which builds for Android, where `LocalizedStringResource`
does not exist. A shared type carrying copy would not compile.

So **the words live with the platform.** Each feature module names the four categories in its own
String Catalog through an extension on the token, and uppercases as its design asks. That the same
four names are spelled out in both `Clock` and `Setup` is the deliberate price of the split — the
alternative is a shared module that only iOS can build.

Tests stay structural, because a token compares by case:

```swift
#expect(presenter.headerModel.category == .classical)
```

and the words are tested where they live, against the catalog that holds them:

```swift
#expect(String(localized: RulesetCategory.blitz.name) == "Blitz")
```

The generated catalog symbols (`.blitzCategory`) are **internal to the module that owns the
catalog**, so a consumer names the accessor, never the symbol.

### Identity crosses as an id

**No domain type reaches a view — not another module's, and not the feature's own.** A `Model` carries
what the view draws plus what it needs to report an interaction, and nothing else:

```swift
struct Model: Identifiable {

    let id: String
    let category: LocalizedStringResource
    let description: LocalizedStringResource
    let baseMinutes: Int
    let incrementSeconds: Int
    let isSelected: Bool

}
```

The `id` is already there for `Identifiable`, so interaction costs the model nothing extra: the
`Action` hands the same id back, and the Presenter turns it into the domain value.

```swift
case select(id: String)

func selectRuleset(id: String) {
    guard let ruleset = PresetRuleset(rawValue: id) else { return }

    select(ruleset)
}
```

Where a model needs copy, it is built in **two steps**. The Presenter exposes a pure model carrying
the id, the tokens and the numbers; the feature's view turns that into the model its subview takes,
adding the words. `SetupPresenter` hands out a `RulesetModel`, and `SetupView` makes the
`RulesetCell.Model` above from it. The Presenter still decides what is on screen and in what order —
it just does not decide what any of it is called.

This is why a preset's raw values are **stable keys** rather than derived from its numbers — the id
is the identity the view round-trips, so it has to survive a preset's values being revised.

The `guard` is the price: an id the Presenter did not issue cannot occur, and the branch exists only
because the type system cannot say so. That is cheaper than a domain type in a view, which lets a
rule change reach the presentation layer with nothing to stop it.

`Player`, `GameState` and `PlayerClock` never cross for the same reason, and where a view needs an
identity of its own it declares one — `ClockFace.Side`.

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

**A presenter names nothing.** Not the sentence, and not the word inside it — it hands over a token
and the view says what it is called. `BLITZ · 3 | 2` is the header's phrasing of a category the
presenter only classified.

Presenters are platform code now, so this is a design rule rather than a compiler one: a presenter
that returns a finished sentence has become a string factory, and the format string stops being whole
for a translator. The token it classifies still comes from `Shared`, which carries no copy at all.

---

## Domain Layer

### Service

Anything that **holds state or owns rules** is a Service. Services live in `Shared`, under
`Sources/Shared/<Screen>/Services/`, because the rules are the same on every platform — and a
platform reads them through a **snapshot**: one value carrying what is true right now, per-clock
remaining time and status, whose turn it is, the move number and the winner.

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
- Never leak a domain type that carries behaviour or state into a View's `Model` or `Action`. A name
  crosses as a token the view resolves, an identity as its id; see the two sections above.
- Nothing in `Shared` imports `SwiftUI` or `CoreUI`, or references `LocalizedStringResource`.
- **`Shared` holds no presentation.** No presenter, no view model, no routing protocol, no UI state.
  Each platform writes its own over the same domain.
- **A rule that decides what is true belongs in `Shared`**, even when a presenter is what used to ask
  it — the low-time threshold, who may start, the move number, a clock's status. If two platforms
  would otherwise have to agree by hand, it is domain.
- Single source of truth at every layer. A Presenter computes from the Service's snapshot rather than
  keeping its own copy.
- One Presenter per View. Do not share Presenters between Views.
- State-holding components are Services in `Services/`, not UseCases.
- Feature modules never import each other. Communication goes through a protocol the app satisfies.
- Do not add layers for data the app does not have.
