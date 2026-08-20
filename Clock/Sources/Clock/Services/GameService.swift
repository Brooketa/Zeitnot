import Core

final class GameService: GameServiceProtocol {

    var state: GameState {
        switch countdownState {
        case .notStarted: makeState(phase: .notStarted)
        case let .running(player, since): makeRunningState(player: player, since: since)
        case let .paused(player): makeState(phase: .paused(player: player))
        }
    }

    private let timeControl: TimeControl
    private let timeSource: TimeSourceProtocol

    private var countdownState: CountdownState = .notStarted
    private var white: PlayerClock
    private var black: PlayerClock

    private var increment: Duration {
        .seconds(timeControl.incrementSeconds)
    }

    init(timeControl: TimeControl, timeSource: TimeSourceProtocol) {
        self.timeControl = timeControl
        self.timeSource = timeSource
        white = Self.makeClock(for: timeControl)
        black = Self.makeClock(for: timeControl)
    }

    func start() {
        guard case .notStarted = countdownState else { return }

        countdownState = .running(player: .white, since: timeSource.now)
    }

    func endTurn() {
        guard case let .running(player, since) = countdownState else { return }

        let now = timeSource.now
        let remaining = remaining(for: player, since: since, at: now)

        guard remaining > .zero else { return }

        self[player].remaining = remaining + increment
        self[player].moveCount += 1
        countdownState = .running(player: player.opponent, since: now)
    }

    func pause() {
        guard case let .running(player, since) = countdownState else { return }

        let remaining = remaining(for: player, since: since, at: timeSource.now)

        guard remaining > .zero else { return }

        self[player].remaining = remaining
        countdownState = .paused(player: player)
    }

    func resume() {
        guard case let .paused(player) = countdownState else { return }

        countdownState = .running(player: player, since: timeSource.now)
    }

    func reset() {
        white = Self.makeClock(for: timeControl)
        black = Self.makeClock(for: timeControl)
        countdownState = .notStarted
    }

}

private extension GameService {

    enum CountdownState {

        case notStarted
        case running(player: Player, since: ContinuousClock.Instant)
        case paused(player: Player)

    }

    enum Constants {

        static let secondsPerMinute = 60

    }

    subscript(player: Player) -> PlayerClock {
        get {
            switch player {
            case .white: white
            case .black: black
            }
        }
        set {
            switch player {
            case .white: white = newValue
            case .black: black = newValue
            }
        }
    }

    static func makeClock(for timeControl: TimeControl) -> PlayerClock {
        PlayerClock(
            remaining: .seconds(timeControl.baseMinutes * Constants.secondsPerMinute),
            moveCount: 0)
    }

    func makeState(phase: GameState.Phase) -> GameState {
        GameState(phase: phase, white: white, black: black)
    }

    func makeRunningState(player: Player, since: ContinuousClock.Instant) -> GameState {
        var clock = self[player]
        clock.remaining = remaining(for: player, since: since, at: timeSource.now)

        let phase: GameState.Phase = clock.remaining > .zero ?
            .running(player: player) :
            .finished(winner: player.opponent)

        return GameState(
            phase: phase,
            white: player == .white ? clock : white,
            black: player == .black ? clock : black)
    }

    func remaining(
        for player: Player,
        since: ContinuousClock.Instant,
        at now: ContinuousClock.Instant
    ) -> Duration {
        max(self[player].remaining - (now - since), .zero)
    }

}
