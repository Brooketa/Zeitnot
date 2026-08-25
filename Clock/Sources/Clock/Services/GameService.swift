import Observation
import Core

@Observable
public final class GameService: GameServiceProtocol {

    public private(set) var state: GameState

    private let timeControl: TimeControl
    private let timeSource: TimeSourceProtocol
    private let ticker: TickerProtocol

    private var countdownState: CountdownState = .notStarted {
        didSet {
            syncTicking()
            publish()
        }
    }

    private var clocks: PlayerClocks

    public init(timeControl: TimeControl, timeSource: TimeSourceProtocol, ticker: TickerProtocol) {
        let clock = Self.makeClock(for: timeControl)

        self.timeControl = timeControl
        self.timeSource = timeSource
        self.ticker = ticker
        clocks = PlayerClocks(white: clock, black: clock)
        state = GameState(phase: .notStarted, white: clock, black: clock)
    }

    public func start() {
        guard case .notStarted = countdownState else { return }

        countdownState = .running(player: .white, since: timeSource.now)
    }

    public func endTurn() {
        guard case let .running(player, since) = countdownState else { return }

        let now = timeSource.now
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

        let remaining = remaining(for: player, since: since, at: timeSource.now)

        guard remaining > .zero else {
            flag(losingPlayer: player)
            return
        }

        clocks[player].remaining = remaining
        countdownState = .paused(player: player)
    }

    public func resume() {
        guard case let .paused(player) = countdownState else { return }

        countdownState = .running(player: player, since: timeSource.now)
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
        guard case let .running(player, since) = countdownState else { return }

        guard remaining(for: player, since: since, at: timeSource.now) > .zero else {
            flag(losingPlayer: player)
            return
        }

        publish()
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

// MARK: Publishing

private extension GameService {

    func publish() {
        state = makeState()
    }

    func makeState() -> GameState {
        switch countdownState {
        case .notStarted: makeState(phase: .notStarted)
        case let .running(player, since): makeRunningState(player: player, since: since)
        case let .paused(player): makeState(phase: .paused(player: player))
        case let .finished(winner): makeState(phase: .finished(winner: winner))
        }
    }

    func makeState(phase: GameState.Phase) -> GameState {
        GameState(phase: phase, white: clocks.white, black: clocks.black)
    }

    func makeRunningState(player: Player, since: ContinuousClock.Instant) -> GameState {
        var clock = clocks[player]
        clock.remaining = remaining(for: player, since: since, at: timeSource.now)

        return GameState(
            phase: .running(player: player),
            white: player == .white ? clock : clocks.white,
            black: player == .black ? clock : clocks.black)
    }

}
