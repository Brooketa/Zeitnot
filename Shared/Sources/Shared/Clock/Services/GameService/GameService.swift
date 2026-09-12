import Observation

@Observable
public final class GameService: GameServiceProtocol {

    private let timeControl: TimeControl
    private let timeSource: TimeSourceProtocol
    private let ticker: TickerProtocol

    private var countdownState: CountdownState = .notStarted {
        didSet {
            syncTicking()
        }
    }

    private var clocks: PlayerClocks
    private var now: ContinuousClock.Instant

    public init(timeControl: TimeControl, timeSource: TimeSourceProtocol, ticker: TickerProtocol) {
        let clock = Self.makeClock(for: timeControl)

        self.timeControl = timeControl
        self.timeSource = timeSource
        self.ticker = ticker
        clocks = PlayerClocks(white: clock, black: clock)
        now = timeSource.now
    }

    public var snapshot: GameSnapshot {
        makeSnapshot()
    }

    public func press(_ player: Player) {
        switch countdownState {
        case .notStarted where player == .black: start()
        case let .running(active, _) where active == player: endTurn()
        default: break
        }
    }

    func start() {
        guard case .notStarted = countdownState else { return }

        now = timeSource.now
        countdownState = .running(player: .white, since: now)
    }

    func endTurn() {
        guard case let .running(player, since) = countdownState else { return }

        now = timeSource.now

        let remaining = remaining(for: player, since: since, at: now)

        guard remaining > .zero else {
            flag(losingPlayer: player)
            return
        }

        let clock = clocks[player]

        clocks[player] = PlayerClock(remaining: remaining + timeControl.increment, moveCount: clock.moveCount + 1)
        countdownState = .running(player: player.opponent, since: now)
    }

    public func pause() {
        guard case let .running(player, since) = countdownState else { return }

        now = timeSource.now

        let remaining = remaining(for: player, since: since, at: now)

        guard remaining > .zero else {
            flag(losingPlayer: player)
            return
        }

        clocks[player].remaining = remaining
        countdownState = .paused(player: player)
    }

    public func resume() {
        guard case let .paused(player) = countdownState else { return }

        now = timeSource.now
        countdownState = .running(player: player, since: now)
    }

    public func reset() {
        let clock = Self.makeClock(for: timeControl)

        clocks = PlayerClocks(white: clock, black: clock)
        countdownState = .notStarted
    }

}

// MARK: Constants

private extension GameService {

    enum Constants {

        static let tickInterval = Duration.milliseconds(100)
        static let warningThreshold = Duration.seconds(10)
        static let warningShareOfBaseTime = 10

    }

}

// MARK: Countdown

private extension GameService {

    enum CountdownState {

        case notStarted
        case running(player: Player, since: ContinuousClock.Instant)
        case paused(player: Player)
        case finished(winner: Player)

        var isRunning: Bool {
            if case .running = self { true } else { false }
        }

    }

    func syncTicking() {
        if countdownState.isRunning {
            startTicking()
        } else {
            stopTicking()
        }
    }

    func startTicking() {
        ticker.start(interval: Constants.tickInterval) { [weak self] in
            guard let self else { return }

            tick()
        }
    }

    func stopTicking() {
        ticker.stop()
    }

    func tick() {
        now = timeSource.now

        guard case let .running(player, since) = countdownState else { return }
        guard remaining(for: player, since: since, at: now) <= .zero else { return }

        flag(losingPlayer: player)
    }

    func flag(losingPlayer: Player) {
        clocks[losingPlayer].remaining = .zero
        countdownState = .finished(winner: losingPlayer.opponent)
    }

    func remaining(for player: Player, since: ContinuousClock.Instant, at now: ContinuousClock.Instant) -> Duration {
        max(clocks[player].remaining - (now - since), .zero)
    }

    static func makeClock(for timeControl: TimeControl) -> PlayerClock {
        PlayerClock(remaining: timeControl.baseTime, moveCount: 0)
    }

}

// MARK: Snapshot

private extension GameService {

    var playerToMove: Player {
        switch countdownState {
        case let .running(player, _), let .paused(player): player
        case .notStarted, .finished: .white
        }
    }

    var winner: Player? {
        guard case let .finished(winner) = countdownState else { return nil }

        return winner
    }

    var isAwaitingStart: Bool {
        if case .notStarted = countdownState { true } else { false }
    }

    var isPaused: Bool {
        if case .paused = countdownState { true } else { false }
    }

    var warningThreshold: Duration {
        min(Constants.warningThreshold, timeControl.baseTime / Constants.warningShareOfBaseTime)
    }

    func makeSnapshot() -> GameSnapshot {
        let clocks = liveClocks()

        return GameSnapshot(
            white: makeClockSnapshot(for: .white, clocks: clocks),
            black: makeClockSnapshot(for: .black, clocks: clocks),
            playerToMove: playerToMove,
            moveNumber: clocks.black.moveCount + 1,
            winner: winner,
            isAwaitingStart: isAwaitingStart,
            isRunning: countdownState.isRunning,
            isPaused: isPaused,
            isFinished: winner != nil)
    }

    func liveClocks() -> PlayerClocks {
        guard case let .running(player, since) = countdownState else { return clocks }

        var clocks = clocks
        clocks[player].remaining = remaining(for: player, since: since, at: now)

        return clocks
    }

    func makeClockSnapshot(for player: Player, clocks: PlayerClocks) -> ClockSnapshot {
        ClockSnapshot(
            remaining: clocks[player].remaining,
            moveCount: clocks[player].moveCount,
            status: status(for: player, clocks: clocks))
    }

    func status(for player: Player, clocks: PlayerClocks) -> ClockStatus {
        switch countdownState {
        case .notStarted: .awaitingStart
        case let .running(active, _): runningStatus(for: player, active: active, clocks: clocks)
        case let .paused(active): active == player ? .toMove : .waiting
        case let .finished(winner): winner == player ? .waiting : .flagged
        }
    }

    func runningStatus(for player: Player, active: Player, clocks: PlayerClocks) -> ClockStatus {
        guard active == player else { return .waiting }

        return clocks[player].remaining <= warningThreshold ? .lowTime : .toMove
    }

}
