import Observation

@Observable
public final class ClockPresenter {

    public var displayMode: DisplayMode = .digital
    public private(set) var showResetDialog = false

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

    public var headerModel: HeaderModel {
        HeaderModel(
            category: gameConfiguration.category,
            baseMinutes: timeControl.baseMinutes,
            incrementSeconds: timeControl.incrementSeconds,
            moveNumber: state.black.moveCount + 1,
            isRunning: isCountingDown)
    }

    public var clocksModel: ClocksModel {
        ClocksModel(white: makeClockModel(for: .white), black: makeClockModel(for: .black))
    }

    public var controlBarModel: ControlBarModel {
        ControlBarModel(canPause: isCountingDown, canReset: isCountingDown || isGameOver)
    }

    public var pauseDialogModel: PauseDialogModel {
        PauseDialogModel(playerToMove: dialogPlayer(for: playerToMove))
    }

    public var showPauseDialog: Bool {
        if case .paused = state.phase { true } else { false }
    }

    public var isCountingDown: Bool {
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

    public func navigateBack() {
        router.navigateBack()
    }

    public func press(_ side: ClockFaceSide) {
        let player = player(for: side)

        switch state.phase {
        case .notStarted where player == .black: gameService.start()
        case let .running(active) where active == player: gameService.endTurn()
        default: break
        }
    }

    public func pause() {
        gameService.pause()
    }

    public func resume() {
        gameService.resume()
    }

    public func reset() {
        guard isGameInProgress else {
            gameService.reset()
            return
        }

        showResetDialog = true
    }

    public func confirmReset() {
        gameService.reset()
        showResetDialog = false
    }

    public func cancelReset() {
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

    func makeClockModel(for player: Player) -> ClockFaceModel {
        ClockFaceModel(
            side: side(for: player),
            state: faceState(for: player),
            timeDisplay: timeDisplay(for: player))
    }

    func timeDisplay(for player: Player) -> ClockFaceTimeDisplay {
        switch displayMode {
        case .digital: .digital(DigitalFaceModel(reading: state[player].remaining.timeReading))
        case .analog: .analog(AnalogFaceModel(hands: DialHands(remaining: state[player].remaining)))
        }
    }

    func side(for player: Player) -> ClockFaceSide {
        switch player {
        case .white: .white
        case .black: .black
        }
    }

    func player(for side: ClockFaceSide) -> Player {
        switch side {
        case .white: .white
        case .black: .black
        }
    }

    func dialogPlayer(for player: Player) -> PauseDialogPlayer {
        switch player {
        case .white: .white
        case .black: .black
        }
    }

    func faceState(for player: Player) -> ClockFaceState {
        switch state.phase {
        case .notStarted: .awaitingStart
        case let .running(active): runningFaceState(for: player, active: active)
        case let .paused(active): active == player ? .toMove : .waiting
        case let .finished(winner): winner == player ? .waiting : .flagged
        }
    }

    func runningFaceState(for player: Player, active: Player) -> ClockFaceState {
        guard active == player else { return .waiting }

        return state[player].remaining <= warningThreshold ? .lowTime : .toMove
    }

}
