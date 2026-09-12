public struct GameSnapshot: Equatable, Sendable {

    public let white: ClockSnapshot
    public let black: ClockSnapshot
    public let playerToMove: Player
    public let moveNumber: Int
    public let winner: Player?
    public let isAwaitingStart: Bool
    public let isRunning: Bool
    public let isPaused: Bool
    public let isFinished: Bool

    public var isInProgress: Bool {
        isRunning || isPaused
    }

    public subscript(player: Player) -> ClockSnapshot {
        switch player {
        case .white: white
        case .black: black
        }
    }

}
