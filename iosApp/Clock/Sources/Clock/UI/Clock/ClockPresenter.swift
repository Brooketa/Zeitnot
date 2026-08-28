import Observation
import Core

@Observable
public final class ClockPresenter {

    var displayMode: DisplayMode = .digital
    private(set) var showResetDialog = false

    private let gameConfiguration: GameConfiguration
    private let gameService: any GameServiceProtocol
    private let router: any ClockRoutingProtocol

    public init(
        gameConfiguration: GameConfiguration,
        gameService: any GameServiceProtocol,
        router: any ClockRoutingProtocol
    ) {
        self.gameConfiguration = gameConfiguration
        self.gameService = gameService
        self.router = router
    }

    var headerModel: Header.Model {
        Header.Model(
            category: gameConfiguration.category,
            baseMinutes: timeControl.baseMinutes,
            incrementSeconds: timeControl.incrementSeconds,
            moveNumber: state.black.moveCount + 1,
            isRunning: isCountingDown)
    }

    var clocksModel: Clocks.Model {
        Clocks.Model(white: makeClockModel(for: .white), black: makeClockModel(for: .black))
    }

    var controlBarModel: ControlBar.Model {
        ControlBar.Model(canPause: isCountingDown, canReset: isCountingDown || isGameOver)
    }

    var pauseDialogModel: PauseDialog.Model {
        PauseDialog.Model(playerToMove: dialogPlayer(for: playerToMove))
    }

    var showPauseDialog: Bool {
        if case .paused = state.phase { true } else { false }
    }

    var isCountingDown: Bool {
        if case .running = state.phase { true } else { false }
    }

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

    private var warningThreshold: Duration {
        min(Constants.warningThreshold, timeControl.baseTime / Constants.warningShareOfBaseTime)
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

// MARK: Constants

private extension ClockPresenter {

    enum Constants {

        static let warningThreshold: Duration = .seconds(10)
        static let warningShareOfBaseTime = 10

    }

}

// MARK: Mappers

private extension ClockPresenter {

    func makeClockModel(for player: Player) -> ClockFace.Model {
        ClockFace.Model(
            side: side(for: player),
            state: faceState(for: player),
            timeDisplay: timeDisplay(for: player))
    }

    func timeDisplay(for player: Player) -> ClockFace.TimeDisplay {
        switch displayMode {
        case .digital: .digital(DigitalFace.Model(reading: state[player].remaining.timeReading))
        case .analog: .analog(AnalogFace.Model(hands: DialHands(remaining: state[player].remaining)))
        }
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

    func dialogPlayer(for player: Player) -> PauseDialog.Player {
        switch player {
        case .white: .white
        case .black: .black
        }
    }

    func faceState(for player: Player) -> ClockFace.State {
        switch state.phase {
        case .notStarted: .awaitingStart
        case let .running(active): runningFaceState(for: player, active: active)
        case let .paused(active): active == player ? .toMove : .waiting
        case let .finished(winner): winner == player ? .waiting : .flagged
        }
    }

    func runningFaceState(for player: Player, active: Player) -> ClockFace.State {
        guard active == player else { return .waiting }

        return state[player].remaining <= warningThreshold ? .lowTime : .toMove
    }

}
