import Core
@testable import Setup

final class SetupRoutingSpy: SetupRoutingProtocol {

    private(set) var routedGameConfigurations: [GameConfiguration] = []

    func navigateToClock(gameConfiguration: GameConfiguration) {
        routedGameConfigurations.append(gameConfiguration)
    }

}
