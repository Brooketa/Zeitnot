import Foundation
import Observation
import Core

@Observable
public final class ClockPresenter {

    public var title: String {
        String(localized: .rulesetTitle(category, timeControl.baseMinutes, timeControl.incrementSeconds))
    }

    private let gameConfiguration: GameConfiguration

    private var category: String {
        gameConfiguration.category.uppercased()
    }

    private var timeControl: TimeControl {
        gameConfiguration.timeControl
    }

    public init(gameConfiguration: GameConfiguration) {
        self.gameConfiguration = gameConfiguration
    }

}
