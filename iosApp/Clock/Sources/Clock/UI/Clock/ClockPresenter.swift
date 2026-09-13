import Observation
import Shared

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
            moveNumber: snapshot.moveNumber,
            isRunning: snapshot.isRunning)
    }

    var clocksModel: Clocks.Model {
        Clocks.Model(white: makeClockModel(for: .white), black: makeClockModel(for: .black))
    }

    var controlBarModel: ControlBar.Model {
        ControlBar.Model(canPause: snapshot.isRunning, canReset: snapshot.isRunning || snapshot.isFinished)
    }

    var pauseDialogModel: PauseDialog.Model {
        PauseDialog.Model(playerToMove: dialogPlayer(for: snapshot.playerToMove))
    }

    var showPauseDialog: Bool {
        snapshot.isPaused
    }

    var isCountingDown: Bool {
        snapshot.isRunning
    }

    private var snapshot: GameSnapshot {
        gameService.snapshot
    }

    private var timeControl: TimeControl {
        gameConfiguration.timeControl
    }

    func navigateBack() {
        router.navigateBack()
    }

    func press(_ side: ClockFace.Side) {
        gameService.press(player(for: side))
    }

    func pause() {
        gameService.pause()
    }

    func resume() {
        gameService.resume()
    }

    func reset() {
        guard snapshot.isInProgress else {
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
            state: faceState(for: snapshot[player].status),
            timeDisplay: timeDisplay(for: player))
    }

    func timeDisplay(for player: Player) -> ClockFace.TimeDisplay {
        switch displayMode {
        case .digital: .digital(DigitalFace.Model(reading: snapshot[player].remaining.timeReading))
        case .analog: .analog(AnalogFace.Model(hands: DialHands(remaining: snapshot[player].remaining)))
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

    func faceState(for status: ClockStatus) -> ClockFace.State {
        switch status {
        case .awaitingStart: .awaitingStart
        case .toMove: .toMove
        case .lowTime: .lowTime
        case .waiting: .waiting
        case .flagged: .flagged
        }
    }

}
