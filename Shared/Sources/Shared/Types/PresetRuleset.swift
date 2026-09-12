public nonisolated enum PresetRuleset: String, CaseIterable, Identifiable, Sendable {

    case bullet1plus0 = "bullet-1-0"
    case blitz3plus2 = "blitz-3-2"
    case blitz5plus0 = "blitz-5-0"
    case rapid10plus0 = "rapid-10-0"
    case rapid15plus10 = "rapid-15-10"
    case classical90plus30 = "classical-90-30"

}

public nonisolated extension PresetRuleset {

    var id: String {
        rawValue
    }

    var timeControl: TimeControl {
        switch self {
        case .bullet1plus0: .bullet1plus0
        case .blitz3plus2: .blitz3plus2
        case .blitz5plus0: .blitz5plus0
        case .rapid10plus0: .rapid10plus0
        case .rapid15plus10: .rapid15plus10
        case .classical90plus30: .classical90plus30
        }
    }

    var category: RulesetCategory {
        switch self {
        case .bullet1plus0: .bullet
        case .blitz3plus2, .blitz5plus0: .blitz
        case .rapid10plus0, .rapid15plus10: .rapid
        case .classical90plus30: .classical
        }
    }

}
