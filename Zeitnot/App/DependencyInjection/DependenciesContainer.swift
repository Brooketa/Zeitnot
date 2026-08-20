import SwiftUI

private struct DependenciesContainer {

    let dependencies: Dependencies!

    enum Key: EnvironmentKey {

        static let defaultValue = DependenciesContainer(dependencies: nil)

    }

}

private extension EnvironmentValues {

    var dependenciesContainer: DependenciesContainer {
        get { self[DependenciesContainer.Key.self] }
        set { self[DependenciesContainer.Key.self] = newValue }
    }

}

extension View {

    func environment(dependencies: Dependencies) -> some View {
        environment(\.dependenciesContainer, DependenciesContainer(dependencies: dependencies))
    }

}

extension EnvironmentValues {

    var dependencies: Dependencies { dependenciesContainer.dependencies }

}
