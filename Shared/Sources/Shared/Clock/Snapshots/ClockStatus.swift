public enum ClockStatus: Equatable, Sendable {

    case awaitingStart
    case toMove
    case lowTime
    case waiting
    case flagged

}
