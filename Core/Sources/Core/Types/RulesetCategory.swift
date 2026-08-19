public enum RulesetCategory: String, CaseIterable, Codable, Sendable {

    case bullet
    case blitz
    case rapid
    case classical
    case custom

    public var title: String {
        switch self {
        case .bullet: "Bullet"
        case .blitz: "Blitz"
        case .rapid: "Rapid"
        case .classical: "Classical"
        case .custom: "Custom"
        }
    }

}
