import Shared

public struct RulesetModel: Identifiable {

    public let id: String
    public let category: RulesetCategory
    public let baseMinutes: Int
    public let incrementSeconds: Int
    public let isSelected: Bool

}
