# Project Structure

## Overview

This project follows a **feature-first modular architecture**, where each module encapsulates one large, self-contained feature. All modules are managed as local Swift packages via **Swift Package Manager (SPM)** and referenced directly by the `Zeitnot` Xcode project (`iosApp/Zeitnot.xcodeproj`) — there is no `.xcworkspace`.

Modules are organized in a strict dependency hierarchy. A module may only depend on modules **lower** in the hierarchy — never on sibling feature modules or modules above it.

```
App (main target)
 └── Feature Modules  (e.g. Authentication, Dashboard, Settings)
      ├── GameDomain   (what the game is — no UI)
      └── CoreUI       (how anything is drawn — no domain)
```

The two base modules are **independent of each other**, not a chain: one knows the game and nothing about drawing, the other knows drawing and nothing about the game. Neither imports the other, and a feature takes both.

No circular dependencies are permitted. Feature modules must not import each other directly — shared communication should be done through protocols defined in `GameDomain` or via the App target as a coordinator.

---

## Module Hierarchy

### GameDomain

The `GameDomain` module is the **game's shared vocabulary** — the types every feature means the same thing by, together with the words for them. It is non-UI: `Foundation` only.

**What belongs here:**
- Domain value types and tokens used by **more than one feature** (`TimeControl`, `RulesetCategory`, `GameConfiguration`)
- The **copy naming those types** — its own String Catalog, reached through generated symbols
- Domain formatting every screen must agree on (the shared time reading)
- Shared protocols and interfaces used across features

**What does NOT belong here:**
- Anything that imports `SwiftUI` or `UIKit`
- A type only one feature uses, however domain-shaped it looks. `PresetRuleset` is the setup screen's and lives there, its descriptions with it
- Sentences a *screen* writes. A category's name is the category's; `BLITZ · 3 | 2` is the clock header's
- Business logic or state specific to a single feature — a Service lives with its feature

**Dependencies:** None. `GameDomain` is a zero-dependency module.

**There is no generic `Core`.** Nothing in the app today is a non-UI utility without game meaning, and a module holding nothing is ceremony. If one appears — a `String` extension, a `Debouncer` — add `Core` beneath both base modules then, rather than parking it in `GameDomain` because it has nowhere else to go.

---

### CoreUI

The `CoreUI` module contains all **reusable UI building blocks** — anything SwiftUI-related that is used across two or more feature modules.

**What belongs here:**
- Custom `ViewModifier`s (e.g. `readHeightModifier`, `roundedCardModifier`, background/padding style modifiers)
- View extensions (e.g. `.onFirstAppear()`, `.conditionalModifier()`)
- Reusable UI components (e.g. `PrimaryButton`, `CustomTextField`, `LoadingOverlay`, `EmptyStateView`)
- Design system tokens (typography, color palette, spacing constants), grouped under `Design/` with
  one subfolder per token family — `Design/Colors/`, `Design/Typography/`, `Design/Spacing/`
- Images and assets shared across modules (e.g. `AppImages` enum wrapping `ImageResource`)
- Custom `Shape`s and `Style`s (e.g. `RoundedCornerShape`)
- SwiftUI `PreferenceKey` implementations (e.g. `HeightPreferenceKey`)

**What does NOT belong here:**
- Any business logic or state management
- Feature-specific UI that is only used in one module
- Network or data models

**Dependencies:** None. `CoreUI` knows nothing about the game — it holds no copy and no String Catalog.

---

### Feature Modules

Each feature module represents **one large, user-facing product area**. Examples: `Authentication`, `Dashboard`, `Settings`, `Onboarding`, `Profile`.

**Dependencies:** `GameDomain` and `CoreUI`. Never another feature module.

---

## Full Project Layout

**A package lives with the platforms that use it.** There are two homes, and which one a package
gets is decided by one question — does more than one platform build it?

| Package | Lives in |
|---|---|
| Built by every platform | The **repository root**, beside the platform folders |
| Built by one platform only | That **platform's folder** — `iosApp/`, `androidApp/` |

So the root holds only what is genuinely shared, and each platform folder owns everything that is
its own: its app target, its project file and its platform-only packages. A reader can tell what is
cross-platform by looking at the root, and nothing else has to be checked.

There is still no `Packages/` container directory and no `Features/` grouping directory. Within
whichever home it has, a package sits directly there, side by side with its siblings.

```
Zeitnot/
├── CLAUDE.md
├── Shared/                             # Local Swift package — every platform builds it
├── iosApp/                             # The iOS app and its iOS-only packages
│   ├── Zeitnot.xcodeproj
│   ├── Zeitnot/                        # Main app target
│   │   ├── ZeitnotApp.swift            # @main entry point (SwiftUI App struct)
│   │   ├── App/
│   │   │   ├── Navigation/
│   │   │   │   ├── AppRouter.swift     # Owns the navigation path, conforms to each feature's Routing protocol
│   │   │   │   └── NavigationDestination.swift
│   │   │   └── DependencyInjection/
│   │   │       ├── Dependencies.swift  # Composition root: owns the router, builds presenters
│   │   │       └── DependenciesContainer.swift
│   │   ├── Services/                   # App-level services
│   │   └── Assets.xcassets/            # App-level assets (app icon, accent colour)
│   │
│   ├── GameDomain/                     # Local Swift package — iOS only
│   │   ├── Package.swift
│   │   ├── Docs/
│   │   │   └── GameDomain.md
│   │   └── Sources/
│   │       └── GameDomain/
│   │           ├── Extensions/
│   │           │   ├── Duration+TimeReading.swift
│   │           │   └── ...
│   │           ├── Types/
│   │           │   ├── RulesetCategory.swift
│   │           │   ├── RulesetCategory+Name.swift
│   │           │   └── ...
│   │           └── Resources/
│   │               └── Localization/
│   │                   └── Localizable.xcstrings
│   │
│   ├── CoreUI/                         # Local Swift package — iOS only
│   │   ├── Package.swift
│   │   ├── Docs/
│   │   └── Sources/
│   │       └── CoreUI/
│   │           ├── Design/
│   │           │   ├── Colors/
│   │           │   │   ├── ColorPalette.swift
│   │           │   │   └── Colors.xcassets/
│   │           │   ├── Typography/
│   │           │   │   ├── Typography.swift
│   │           │   │   └── Text+Typography.swift
│   │           │   └── Spacing/
│   │           │       └── CGFloat+Spacing.swift
│   │           ├── Components/
│   │           │   ├── PrimaryButton.swift
│   │           │   └── ...
│   │           ├── Modifiers/
│   │           │   ├── ReadHeightModifier.swift
│   │           │   └── ...
│   │           ├── Extensions/
│   │           │   └── View+Extensions.swift
│   │           └── Images/
│   │               └── AppImages.swift
│   │
│   ├── Setup/                          # Feature package — iOS only
│   │   ├── Package.swift
│   │   ├── Docs/
│   │   │   └── SetupScreen.md
│   │   └── Sources/
│   │       └── Setup/
│   │           └── ...
│   │
│   └── Clock/                          # Feature package — iOS only
│       ├── Package.swift
│       ├── Docs/
│       │   └── ClockScreen.md
│       └── Sources/
│           └── Clock/
│               └── ...
│
└── androidApp/                         # The Android app and its Android-only modules
```

Notes on the tree:

- A package shared by every platform sits at the repository root; a package only one platform
  builds sits inside that platform's folder. Nothing else decides where a package goes.
- A platform folder holds its app target, its project file and its platform-only packages, so it
  can be read on its own without chasing references out to the root.
- The package folder name, the `Package.swift` product name, the target name and the
  `Sources/<Module>/` folder all carry the **same** module name.
- Sources always sit under `Sources/<ModuleName>/`, never directly under `Sources/`.
- `Docs/` holds the module's behavioural spec files (see Workflow → Feature Spec Files). It sits at
  the package root, beside `Package.swift` — not under `Sources/`.
- `CoreUI` groups its design system tokens under `Design/`, with one subfolder per token family
  (`Colors/`, `Typography/`, `Spacing/`). Asset catalogues live beside the code that wraps them and
  are declared as `resources: [.process(...)]` in `Package.swift`.

---

## Referencing A Package In The Xcode Project

A local package is referenced as a **folder reference off the project's main group**, so it appears
in the navigator as a package folder alongside the app target folder.

**Never add a local package through _Package Dependencies_.** That writes an
`XCLocalSwiftPackageReference` into the project's `packageReferences` and parks the package under
the Package Dependencies node. It is the more obvious route in Xcode's UI and it is the wrong one.
`packageReferences` is reserved for *remote* dependencies (`XCRemoteSwiftPackageReference`) — no
local package ever appears there.

Adding a module means four entries in `iosApp/Zeitnot.xcodeproj/project.pbxproj`. Substitute the
module name for `<Module>` throughout:

**1. `PBXFileReference`** — the package folder itself, typed as a `wrapper`. An iOS-only package
sits beside the project inside `iosApp/`, so its path is bare; a shared package lives at the
repository root and is reached with `../`:

```
<UUID_A> /* <Module> */ = {isa = PBXFileReference; lastKnownFileType = wrapper; path = <Module>; sourceTree = "<group>"; };
<UUID_A> /* Shared */ = {isa = PBXFileReference; lastKnownFileType = wrapper; path = ../Shared; sourceTree = "<group>"; };
```

**2. Main group `children`** — so the folder shows in the navigator:

```
children = (
    <UUID_APP_TARGET> /* Zeitnot */,
    <UUID_PRODUCTS> /* Products */,
    <UUID_A> /* <Module> */,
);
```

**3. `XCSwiftPackageProductDependency`** — the product link, carrying **only** `productName`. There
is deliberately no `package` key, because there is no package reference to point at:

```
<UUID_B> /* <Module> */ = {isa = XCSwiftPackageProductDependency; productName = <Module>; };
```

It is listed in the target's `packageProductDependencies`.

**4. `PBXBuildFile`** — links the product, and goes in the target's **Frameworks** build phase:

```
<UUID_C> /* <Module> in Frameworks */ = {isa = PBXBuildFile; productRef = <UUID_B> /* <Module> */; };
```

After adding a module, confirm `packageReferences` still contains no local package.

**Cross-package dependencies** are declared by relative path. Packages in the same home are
siblings, so they reach each other with `../`; a platform-only package reaches a shared one at the
repository root with `../../`:

```swift
dependencies: [
    .package(name: "CoreUI", path: "../CoreUI"),
    .package(name: "Shared", path: "../../Shared")
],
targets: [
    .target(
        name: "Setup",
        dependencies: ["CoreUI", "Shared"])
]
```
---

## Feature Module Internal Structure

Each feature module follows a consistent internal layout:

`Common/` sits **beside** the module's source folder, not inside it, so a reader can tell at a glance
what is screen code and what the whole module shares:

```
FeatureName/
├── Package.swift
└── Sources/
    ├── Common/                             # Shared by every screen in this module
    │   ├── Navigation/                     # The module's routing protocol
    │   │   └── FeatureRoutingProtocol.swift
    │   ├── Extensions/                     # Type extensions scoped to this feature
    │   ├── Images/                         # Images/icons used only within this feature
    │   │   └── Image+Extensions.swift
    │   ├── Components/                     # UI components reused across screens
    │   └── Resources/
    │       └── Localization/
    │           └── Localizable.xcstrings
    └── FeatureName/
        ├── UI/
        │   ├── ScreenOne/
        │   │   ├── ScreenOneView.swift
        │   │   ├── ScreenOnePresenter.swift
        │   │   ├── Components/             # Subviews exclusive to this screen
        │   │   │   └── ScreenOneCard.swift
        │   │   ├── UseCase/
        │   │   │   ├── DomainUseCase.swift
        │   │   │   ├── DomainUseCaseProtocol.swift
        │   │   │   └── DomainUseCaseModel.swift
        │   │   ├── Repository/
        │   │   │   ├── DomainRepository.swift
        │   │   │   ├── DomainRepositoryProtocol.swift
        │   │   │   └── DomainRepositoryModel.swift
        │   │   ├── DataSource/
        │   │   │   ├── DomainDataSource.swift
        │   │   │   ├── DomainDataSourceProtocol.swift
        │   │   │   └── DomainDataSourceModel.swift
        │   │   └── Client/
        │   │       ├── DomainClient.swift
        │   │       ├── DomainClientProtocol.swift
        │   │       └── DomainClientModel.swift
        │   └── ScreenTwo/
        │       └── ...
        └── Models/                         # Optional: shared feature-level models (e.g. SelectedFilter)
```

### Concrete Example — Movies Feature

```
Movies/
└── Sources/
    ├── Common/
    │   ├── Navigation/
    │   │   └── MoviesRoutingProtocol.swift
    │   ├── Extensions/
    │   │   └── Movie+Formatting.swift
    │   ├── Components/
    │   │   └── MovieRatingBadge.swift
    │   ├── Images/
    │   │   └── Image+Extensions.swift
    │   └── Resources/
    │       └── Localization/
    │           └── Localizable.xcstrings
    └── Movies/
        ├── UI/
        │   ├── MovieList/
        │   │   ├── MovieListView.swift
        │   │   ├── MovieListPresenter.swift
        │   │   ├── Components/
        │   │   │   └── MovieListRow.swift
        │   │   ├── UseCase/
        │   │   │   ├── MovieUseCase.swift
        │   │   │   ├── MovieUseCaseProtocol.swift
        │   │   │   └── MovieUseCaseModel.swift
        │   │   ├── Repository/
        │   │   │   ├── MovieRepository.swift
        │   │   │   ├── MovieRepositoryProtocol.swift
        │   │   │   └── MovieRepositoryModel.swift
        │   │   ├── DataSource/
        │   │   │   ├── MovieDataSource.swift
        │   │   │   ├── MovieDataSourceProtocol.swift
        │   │   │   └── MovieDataSourceModel.swift
        │   │   └── Client/
        │   │       ├── MovieClient.swift
        │   │       ├── MovieClientProtocol.swift
        │   │       └── MovieClientModel.swift
        │   └── MovieDetail/
        │       ├── MovieDetailView.swift
        │       ├── MovieDetailPresenter.swift
        │       ├── Components/
        │       │   └── MovieDetailHeroImage.swift
        │       ├── UseCase/
        │       │   ├── MovieUseCase.swift
        │       │   ├── MovieUseCaseProtocol.swift
        │       │   └── MovieUseCaseModel.swift
        │       └── ...
        └── Models/                         # Optional: e.g. SelectedFilter
            └── Movie.swift
```

---

## Layer Responsibilities

**`Common/Navigation/`**
- Holds the module's routing protocol — `FeatureRoutingProtocol` — which is the contract whoever
  navigates the module implements, and the one file in a feature the app target must know about.
- It belongs to the **module**, not to a screen: it says how the app enters and leaves the feature,
  and it serves every screen the module grows. Keeping it in the first screen's folder only works
  while there is one screen.

**`Presenter`**
- Owns the screen's state and drives the `View`
- Calls `UseCase` methods and maps results into view state
- Named `ScreenNamePresenter`

**`UseCase/`**
- Contains business logic for this screen
- `DomainUseCase.swift` — concrete implementation
- `DomainUseCaseProtocol.swift` — abstraction consumed by the Presenter
- `DomainUseCaseModel.swift` — input/output models specific to this use case

**`Repository/`**
- Abstracts over one or more data sources; handles caching or merging logic
- `DomainRepository.swift` — concrete implementation
- `DomainRepositoryProtocol.swift` — abstraction consumed by the UseCase
- `DomainRepositoryModel.swift` — models at the repository boundary

**`DataSource/`**
- Responsible for fetching or persisting data from a single origin (local DB, remote, cache)
- `DomainDataSource.swift` — concrete implementation
- `DomainDataSourceProtocol.swift` — abstraction consumed by the Repository
- `DomainDataSourceModel.swift` — raw models at the data source boundary

**`Client/`**
- Lowest-level networking or SDK wrapper (e.g. URLSession calls, third-party SDK integration)
- `DomainClient.swift` — concrete implementation
- `DomainClientProtocol.swift` — abstraction consumed by the DataSource
- `DomainClientModel.swift` — DTOs (raw request/response models)

### Data Flow

```
View → Presenter → UseCase → Repository → DataSource → Client
                 ↑            ↑              ↑             ↑
           UseCaseModel  RepositoryModel  DataSourceModel  ClientModel
```

Each layer communicates only with the layer directly below it via a **protocol**, passing data using **layer-specific models**. `ClientModel` (raw DTOs) must never leak into the `Presenter`. `UseCaseModel` is always business-logic-shaped, not network-shaped.

---

## Layer File Naming

Files within each layer folder are named after **what they handle** — the domain concept (entity, action, or resource) — not the screen they live in.

**Pattern:** `<DomainConcept><Layer>.swift`

| Layer | File | Purpose |
|---|---|---|
| `UseCase/` | `MovieUseCase.swift` | Concrete use case implementation |
| `UseCase/` | `MovieUseCaseProtocol.swift` | Protocol used by the Presenter |
| `UseCase/` | `MovieUseCaseModel.swift` | Input/output models for this use case |
| `Repository/` | `MovieRepository.swift` | Concrete repository implementation |
| `Repository/` | `MovieRepositoryProtocol.swift` | Protocol used by the UseCase |
| `Repository/` | `MovieRepositoryModel.swift` | Models at the repository boundary |
| `DataSource/` | `MovieDataSource.swift` | Concrete data source implementation |
| `DataSource/` | `MovieDataSourceProtocol.swift` | Protocol used by the Repository |
| `DataSource/` | `MovieDataSourceModel.swift` | Raw models at the data source boundary |
| `Client/` | `MovieClient.swift` | Concrete network/SDK client |
| `Client/` | `MovieClientProtocol.swift` | Protocol used by the DataSource |
| `Client/` | `MovieClientModel.swift` | DTOs (raw request/response models) |

The screen folder name (`MovieList`, `MovieDetail`) describes **the screen's purpose**. The layer file names describe **the domain concept they operate on**. These can differ — a `MovieDetail` screen may reuse the same `MovieClient` and `MovieRepository` as `MovieList` if they operate on the same resource. In that case, move the shared layers to `Common/` within the feature.

---

## Dependency Rules

| Module | Can depend on |
|---|---|
| `GameDomain` | Nothing |
| `CoreUI` | Nothing |
| Feature Module | `GameDomain`, `CoreUI` |
| App Target | All modules |

- **The two base modules never import each other.** `CoreUI` importing `GameDomain` would make the design system game-aware; `GameDomain` importing `CoreUI` would make the domain drawable. Either one collapses the split.
- **No feature-to-feature imports.** If two features need to share something, move it into `GameDomain` (non-UI) or `CoreUI` (UI), or define a protocol in `GameDomain` and inject the implementation from the App target.
- **No upward dependencies.** Lower modules must never import higher ones.
- All new cross-cutting utilities must be evaluated: game vocabulary → `GameDomain`, UI → `CoreUI`, feature-specific → stays in the feature module.

---

## Promotion Rules

| Originally in | Needed by | Move to |
|---|---|---|
| Screen's `Components/` | Another screen in the same feature | `Sources/Common/Components/` |
| Screen's layer (`UseCase/`, `Client/`, etc.) | Another screen in the same feature | `Sources/Common/` |
| `Common/Components/` | Another feature module | `CoreUI/Components/` |
| `Common/Extensions/` | Another feature module | `GameDomain/Extensions/` |
| A type's own copy | The type moved to `GameDomain` | `GameDomain/Resources/Localization/` |
| `Common/Images/` | Another feature module | `CoreUI/Images/` |

---

## Adding a New Module Checklist

1. Decide the package's home: the **repository root** if every platform builds it, otherwise the
   folder of the one platform that does (`iosApp/FeatureName/`). Not under a `Packages/` or
   `Features/` directory either way.
2. Add `Package.swift` with the product, target and `Sources/FeatureName/` folder all named after the
   module, declaring its dependencies by relative path — `../CoreUI` for a sibling, `../../Shared`
   for a shared package at the root.
3. Reference the package folder in `iosApp/Zeitnot.xcodeproj` as a **wrapper folder reference** off the
   project's main group — **not** through _Package Dependencies_. See Referencing A Package In The
   Xcode Project for the exact `project.pbxproj` entries.
4. Link the module product to the App target: an `XCSwiftPackageProductDependency` with only
   `productName`, plus a `PBXBuildFile` in the target's Frameworks build phase. Confirm
   `packageReferences` still contains no local packages.
5. Add a `Docs/` folder at the package root for the module's behavioural spec file(s), and put the
   module's routing protocol in `Sources/Common/Navigation/`.
6. Wire the module's entry screen in: a `NavigationDestination` case, a presenter factory on
   `Dependencies`, and the router's conformance to that module's own `Routing` protocol.
7. Do not import other feature modules — use protocol-based injection if cross-feature communication is needed.

## Adding a New Screen Checklist

1. Create a new folder under `FeatureName/UI/ScreenName/`
2. Add `ScreenNameView.swift` and `ScreenNamePresenter.swift`
3. Add `Components/` and only the layers needed for this screen. Not every screen requires all layers — a screen with no data handling may only need a Presenter. Add `UseCase/`, `Repository/`, `DataSource/`, and `Client/` based on whether the screen needs data and where it comes from.
4. Name layer files after the domain concept they handle, not the screen name
5. If a layer already exists in `Common/` for the same domain concept, reuse it — do not duplicate
