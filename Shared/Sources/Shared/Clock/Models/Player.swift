public enum Player: Equatable, Sendable {

    case white
    case black

    public var opponent: Player {
        self == .white ? .black : .white
    }

}
