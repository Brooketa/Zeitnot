import Foundation
import Observation
import Core

@Observable
public final class ClockPresenter {

    public var title: String {
        String(localized: .rulesetTitle(category, timeControl.baseMinutes, timeControl.incrementSeconds))
    }

    var moveNumber: LocalizedStringResource {
        .moveNumber(state.black.moveCount + 1)
    }

    var whiteClock: ClockFace.Model {
        makeClockModel(for: .white)
    }

    var blackClock: ClockFace.Model {
        makeClockModel(for: .black)
    }

    var isPaused: Bool {
        if case .running = state.phase { false } else { true }
    }

    private let gameConfiguration: GameConfiguration
    private let gameService: GameServiceProtocol

    private var state: GameState {
        gameService.state
    }

    private var category: String {
        gameConfiguration.category.uppercased()
    }

    private var timeControl: TimeControl {
        gameConfiguration.timeControl
    }

    public init(gameConfiguration: GameConfiguration, gameService: GameServiceProtocol) {
        self.gameConfiguration = gameConfiguration
        self.gameService = gameService
    }

    func press(_ side: ClockFace.Side) {
        let player = player(for: side)

        switch state.phase {
        case .notStarted where player == .black: gameService.start()
        case let .running(active) where active == player: gameService.endTurn()
        default: break
        }
    }

    func pause() {
        gameService.pause()
    }

    func reset() {
        gameService.reset()
    }

}

// MARK: Mappers
private extension ClockPresenter {

	func makeClockModel(for player: Player) -> ClockFace.Model {
		ClockFace.Model(
			side: side(for: player),
			name: String(localized: player.name),
			time: state[player].remaining.timeReading,
			caption: caption(for: player),
			state: faceState(for: player))
	}

	func side(for player: Player) -> ClockFace.Side {
		switch player {
		case .white: .white
		case .black: .black
		}
	}

	func player(for side: ClockFace.Side) -> Player {
		switch side {
		case .white: .white
		case .black: .black
		}
	}

	func caption(for player: Player) -> String? {
		let isPromptingToStart = state.phase == .notStarted && player == .black

		return isPromptingToStart ? String(localized: .pressToStart) : nil
	}

	func faceState(for player: Player) -> ClockFace.State {
		switch state.phase {
		case .notStarted: .awaitingStart
		case let .running(active), let .paused(active): active == player ? .toMove : .waiting
		case .finished: .waiting
		}
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
