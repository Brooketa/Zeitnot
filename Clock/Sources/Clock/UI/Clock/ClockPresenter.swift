import Foundation
import Observation
import Core

@Observable
public final class ClockPresenter {

    var headerModel: Header.Model {
        Header.Model(
            category: gameConfiguration.category,
            baseMinutes: timeControl.baseMinutes,
            incrementSeconds: timeControl.incrementSeconds,
            moveNumber: state.black.moveCount + 1,
            isRunning: !isPaused)
    }

    var whiteClock: ClockFace.Model {
        makeClockModel(for: .white)
    }

    var blackClock: ClockFace.Model {
        makeClockModel(for: .black)
    }

    private(set) var showResetDialog = false

    var controlBarModel: ControlBar.Model {
        ControlBar.Model(canPause: !isGameOver)
    }

    var showPauseDialog: Bool {
        if case .paused = state.phase { true } else { false }
    }

    var pauseDialogModel: PauseDialog.Model {
        PauseDialog.Model(playerName: String(localized: playerToMove.name))
    }

    var isPaused: Bool {
        if case .running = state.phase { false } else { true }
    }

    private let gameConfiguration: GameConfiguration
    private let gameService: GameServiceProtocol
    private let router: ClockRoutingProtocol

    private var state: GameState {
        gameService.state
    }

    private var isGameOver: Bool {
        if case .finished = state.phase { true } else { false }
    }

    private var isGameInProgress: Bool {
        switch state.phase {
        case .running, .paused: true
        case .notStarted, .finished: false
        }
    }

    private var playerToMove: Player {
        switch state.phase {
        case let .running(player), let .paused(player): player
        case .notStarted, .finished: .white
        }
    }

    private var timeControl: TimeControl {
        gameConfiguration.timeControl
    }

    public init(
        gameConfiguration: GameConfiguration,
        gameService: GameServiceProtocol,
        router: ClockRoutingProtocol
    ) {
        self.gameConfiguration = gameConfiguration
        self.gameService = gameService
        self.router = router
    }

    func navigateBack() {
        router.navigateBack()
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

    func resume() {
        gameService.resume()
    }

    func reset() {
        guard isGameInProgress else {
            gameService.reset()
            return
        }

        showResetDialog = true
    }

    func confirmReset() {
        gameService.reset()
        showResetDialog = false
    }

    func cancelReset() {
        showResetDialog = false
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
		if case let .finished(winner) = state.phase, winner != player {
			return String(localized: .flagFell)
		}

		let isPromptingToStart = state.phase == .notStarted && player == .black

		return isPromptingToStart ? String(localized: .pressToStart) : nil
	}

	func faceState(for player: Player) -> ClockFace.State {
		switch state.phase {
		case .notStarted: .awaitingStart
		case let .running(active), let .paused(active): active == player ? .toMove : .waiting
		case let .finished(winner): winner == player ? .waiting : .flagged
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
