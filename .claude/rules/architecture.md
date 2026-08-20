# Architecture

This project follows Clean Architecture divided into four strict layers.
Each layer communicates only with the layer directly below it and all
cross-layer dependencies are hidden behind protocols.

**Single source of truth** is a core principle of this architecture at every layer. Data enters the system at the Client level and flows strictly upward. No layer reaches sideways or skips down to fetch data from an alternative source. The Repository decides which DataSource is the source of truth for a given feature; the UseCase trusts the Repository entirely; the Presenter trusts the UseCase entirely.

---

## Layer Overview

```
View -> Presenter -> UseCase -> Repository -> DataSource -> Client -> BaseClient
```

Each layer has its own models. Never pass a model from one layer directly
into another -- always map/convert at the boundary.

---

## Dependency Injection

All dependencies are injected through the constructor (initializer injection). No layer
creates its own dependencies internally. This applies at every level of the architecture:

- View receives Presenter via constructor
- Presenter receives UseCase via constructor
- UseCase receives Repository via constructor
- Repository receives DataSource(s) via constructor
- DataSource receives Client via constructor
- Client (e.g., ItemNetworkClient) receives BaseClient (e.g., BaseNetworkClient) via constructor

All injected dependencies must be expressed as protocols, never as concrete types.
This ensures every component is independently testable and replaceable.

Example:

    final class ItemPresenter: ItemPresenterProtocol {
        private let itemUseCase: ItemUseCaseProtocol

        init(itemUseCase: ItemUseCaseProtocol) {
            self.itemUseCase = itemUseCase
        }
    }

    final class ItemUseCase: ItemUseCaseProtocol {
        private let itemRepository: ItemRepositoryProtocol

        init(itemRepository: ItemRepositoryProtocol) {
            self.itemRepository = itemRepository
        }
    }

    final class ItemRepository: ItemRepositoryProtocol {
        private let remoteDataSource: ItemRemoteDataSourceProtocol

        init(remoteDataSource: ItemRemoteDataSourceProtocol) {
            self.remoteDataSource = remoteDataSource
        }
    }

    final class ItemRemoteDataSource: ItemRemoteDataSourceProtocol {
        private let networkClient: ItemNetworkClientProtocol

        init(networkClient: ItemNetworkClientProtocol) {
            self.networkClient = networkClient
        }
    }

    final class ItemNetworkClient: ItemNetworkClientProtocol {
        private let baseNetworkClient: BaseNetworkClientProtocol

        init(baseNetworkClient: BaseNetworkClientProtocol) {
            self.baseNetworkClient = baseNetworkClient
        }
    }

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
the system and cannot be reached any other way. Anything the app itself builds — every Presenter,
UseCase, Repository, DataSource and Client — takes its dependencies through the constructor,
without exception.

---

## Presentation Layer

### View
- Each View has exactly one Presenter. No exceptions.
- Views are passive -- they only render state provided by the Presenter.
- Views never talk to UseCases, Repositories, or DataSources directly.

### View Model & Action Extensions
- Every view that receives data defines its own `Model` as a nested struct inside an extension on the view.
- Every view that produces user interactions defines its own `Action` as a nested enum inside an extension on the view.
- The Presenter is responsible for constructing the `Model` with all the data the view needs to render.
- The View never sees domain or data-layer models directly -- only its own `Model`.

Example:

    struct ItemCard: View {

        let model: Model
        let action: (Action) -> Void

        var body: some View { ... }

    }

    extension ItemCard {

        struct Model {

            let title: String
            let subtitle: String
            let accentColor: Color
            let isSelected: Bool

        }

    }

    extension ItemCard {

        enum Action {

            case select
            case delete

        }

    }

### Presenter (ViewModel)
- Holds and exposes UI state to the View.
- Calls UseCases to fetch or mutate data.
- Maps UseCase models (ItemUseCaseModel) to Presenter-level view models (View.Model).
- Exposed to the View only through its protocol.

Example:

    func fetchItems() async throws -> [ItemCard.Model] {
        try await itemUseCase.fetchItems()
            .map { ItemCard.Model(from: $0) }
    }

---

## Domain Layer

### UseCase
- One UseCase per feature (e.g., ItemUseCase for everything related to that feature).
- Implements a protocol (e.g., ItemUseCaseProtocol) -- only the protocol is visible to the Presenter.
- Contains business logic. Orchestrates one or more Repositories.
- Trusts the Repository completely -- never decides where data comes from.
- Maps Repository models (ItemRepositoryModel) to UseCase models (ItemUseCaseModel).

Example:

    func fetchItems() async throws -> [ItemUseCaseModel] {
        try await itemRepository.fetchItems()
            .map { ItemUseCaseModel(from: $0) }
    }

---

## Data Layer

The Data Layer is composed of three components: Repository, DataSource, and Client.
Together they form the single source of truth for the entire app -- data enters the
system here and nowhere else.

### Models
Each component in the Data Layer owns its models:
- ItemClientModel -- raw model returned by the Client (e.g., decoded from JSON, BLE packet, etc.)
- ItemDataSourceModel -- model owned by the DataSource, mapped from the Client model
- ItemRepositoryModel -- model owned by the Repository, mapped from the DataSource model

Models never cross component boundaries without being explicitly mapped.

### Repository
- Implements a protocol (e.g., ItemRepositoryProtocol) -- only the protocol is visible to the UseCase.
- Orchestrates one or more DataSources (e.g., remote, local database, Bluetooth).
- Single source of truth: the Repository decides which DataSource data comes from.
  Remote is the default. A local DataSource is only used when the feature explicitly
  requires it (e.g., offline support, user preferences).
- Maps DataSource models (ItemDataSourceModel) to Repository models (ItemRepositoryModel).

Example (remote as source of truth):

    func fetchItems() async throws -> [ItemRepositoryModel] {
        try await remoteDataSource.fetchItems()
            .map { ItemRepositoryModel(from: $0) }
    }

Example (local as source of truth, e.g. after sync):

    func fetchItems() async throws -> [ItemRepositoryModel] {
        let remoteItems = try await remoteDataSource.fetchItems()
        try await databaseDataSource.save(remoteItems)
        return try await databaseDataSource.fetchItems()
            .map { ItemRepositoryModel(from: $0) }
    }

### DataSource
- Implements a protocol (e.g., ItemRemoteDataSourceProtocol) -- only the protocol is visible to the Repository.
- Each DataSource represents exactly one source of data:
  - ItemRemoteDataSource -- fetches data over the network via ItemNetworkClient
  - ItemDatabaseDataSource -- reads/writes to a local database (e.g., SwiftData, CoreData, Realm)
  - ItemBluetoothDataSource -- receives data from a Bluetooth peripheral via ItemBluetoothClient
  - ItemFileDataSource -- reads/writes data from the local file system
- Holds a reference to its underlying Client via constructor injection. Responsible only for
  data retrieval and storage -- no business logic.
- Maps Client models (ItemClientModel) to DataSource models (ItemDataSourceModel).

Example:

    func fetchItems() async throws -> [ItemDataSourceModel] {
        try await itemNetworkClient.fetchItems()
            .map { ItemDataSourceModel(from: $0) }
    }

### Client
- A feature-specific Client (e.g., ItemNetworkClient) exposes named, intent-driven functions
  (e.g., fetchItems(), createItem(_:)). This is the only interface visible to the DataSource.
- Implemented behind a protocol (e.g., ItemNetworkClientProtocol).
- Holds a reference to the corresponding BaseClient via constructor injection and delegates
  the actual execution to it.
- Maps the raw response from BaseClient into Client-level models (e.g., ItemClientModel).
- Each Client type has a corresponding base abstraction:
  - ItemNetworkClient holds BaseNetworkClient (abstraction over URLSession)
  - ItemBluetoothClient holds BaseBluetoothClient (abstraction over CoreBluetooth)
- No business logic lives in the Client -- only request construction and model mapping.

Example:

    // ItemNetworkClientProtocol
    protocol ItemNetworkClientProtocol {
        func fetchItems() async throws -> [ItemClientModel]
    }

    // ItemNetworkClient
    func fetchItems() async throws -> [ItemClientModel] {
        try await baseNetworkClient.execute(ItemEndpoint.fetchAll)
            .map { ItemClientModel(from: $0) }
    }

    // BaseNetworkClientProtocol
    protocol BaseNetworkClientProtocol {
        func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    }

    // BaseNetworkClient
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(from: endpoint)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

---

## Rules

- Every cross-layer dependency must go through a protocol. Never depend on a concrete type across layers.
- All dependencies are injected through the constructor. No component creates its own dependencies.
  The one exception is a service whose consumer UIKit constructs -- see Exception: services UIKit owns
  the lifetime of.
- Never skip layers. A View cannot talk to a UseCase directly; a UseCase cannot talk to a DataSource directly, etc.
- Never leak models across layer boundaries. Each layer owns its models and maps at the boundary.
- Single source of truth at every layer. Each layer has one designated source it trusts -- it never
  reaches sideways or pulls from multiple sources on its own.
- One UseCase per feature. Do not create fat UseCases that span multiple unrelated features.
- One Presenter per View. Do not share Presenters between Views.
- Repository decides the source of truth. Remote is the default; local is only used when
  the feature explicitly requires it.
