public struct Ruleset: Hashable, Sendable {

    public let category: RulesetCategory
    public let timeControl: TimeControl

    public init(category: RulesetCategory, timeControl: TimeControl) {
        self.category = category
        self.timeControl = timeControl
    }

    public var isCustom: Bool {
        category == .custom
    }

}
