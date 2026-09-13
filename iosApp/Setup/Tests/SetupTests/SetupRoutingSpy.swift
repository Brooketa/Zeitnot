@testable import Setup
import Shared

final class SetupRoutingSpy: SetupRoutingProtocol {

    private(set) var routedGameConfigurations: [GameConfiguration] = []

    func navigateToClock(gameConfiguration: GameConfiguration) {
        routedGameConfigurations.append(gameConfiguration)
    }

}
