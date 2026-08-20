import Observation
import Core
import Setup

@Observable
final class AppRouter {

    var navigationPath: [NavigationDestination] = []

    @ObservationIgnored private var isNavigating = false

    func navigationDidComplete() {
        isNavigating = false
    }

    private func append(_ destination: NavigationDestination) {
        guard !isNavigating else { return }

        isNavigating = true
        navigationPath.append(destination)
    }

    fileprivate func navigateBack() {
        guard !navigationPath.isEmpty else { return }

        navigationPath.removeLast()
    }

}

// MARK: - SetupRoutingProtocol

extension AppRouter: SetupRoutingProtocol {

    func navigateToClock(gameConfiguration: GameConfiguration) {
        append(.clock(gameConfiguration))
    }

}
