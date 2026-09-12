public nonisolated struct GameConfiguration: Hashable, Sendable {

    public let timeControl: TimeControl
    public let category: RulesetCategory

    public init(timeControl: TimeControl, category: RulesetCategory) {
        self.timeControl = timeControl
        self.category = category
    }

}
