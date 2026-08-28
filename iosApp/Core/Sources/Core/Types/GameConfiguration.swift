public struct GameConfiguration: Hashable, Sendable {

    public let timeControl: TimeControl
    public let category: String

    public init(timeControl: TimeControl, category: String) {
        self.timeControl = timeControl
        self.category = category
    }

}
