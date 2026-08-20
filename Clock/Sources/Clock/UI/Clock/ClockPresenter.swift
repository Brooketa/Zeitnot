import Foundation
import Observation
import Core

@Observable
public final class ClockPresenter {

    public var title: String {
        String(localized: .rulesetTitle(category, timeControl.baseMinutes, timeControl.incrementSeconds))
    }

    var moveNumber: LocalizedStringResource {
        .moveNumber(state.white.moveCount + 1)
    }

    var whiteClock: ClockFace.Model {
        makeClockModel(for: .white)
    }

    var blackClock: ClockFace.Model {
        makeClockModel(for: .black)
    }

    private let gameConfiguration: GameConfiguration
    private let gameService: GameServiceProtocol

    private var state: GameState

    private var category: String {
        gameConfiguration.category.uppercased()
    }

    private var timeControl: TimeControl {
        gameConfiguration.timeControl
    }

    public init(gameConfiguration: GameConfiguration, gameService: GameServiceProtocol) {
        self.gameConfiguration = gameConfiguration
        self.gameService = gameService
        state = gameService.state
    }

    func startTicking() async {
        while !Task.isCancelled {
            refresh()
            try? await Task.sleep(for: Constants.tickInterval)
        }
    }

    func handle(_ action: ControlBar.Action) {
        switch action {
        case .pause: gameService.pause()
        case .reset: gameService.reset()
        }

        refresh()
    }

}

private extension ClockPresenter {

    enum Constants {

        static let tickInterval: Duration = .milliseconds(100)

    }

    func refresh() {
        let latest = gameService.state

        guard latest != state else { return }

        state = latest
    }

}

private extension Player {

	var name: LocalizedStringResource {
		switch self {
		case .white: .whitePlayer
		case .black: .blackPlayer
		}
	}

}

// MARK: Mappers
private extension ClockPresenter {

	func makeClockModel(for player: Player) -> ClockFace.Model {
		ClockFace.Model(
			player: String(localized: player.name),
			time: state[player].remaining.timeReading,
			state: faceState(for: player))
	}

	func faceState(for player: Player) -> ClockFace.State {
		switch state.phase {
		case .notStarted: .awaitingStart
		case let .running(active), let .paused(active): active == player ? .toMove : .waiting
		case .finished: .waiting
		}
	}

}
