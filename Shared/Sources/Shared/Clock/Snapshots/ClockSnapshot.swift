public struct ClockSnapshot: Equatable, Sendable {

    public let remaining: Duration
    public let moveCount: Int
    public let status: ClockStatus

}
