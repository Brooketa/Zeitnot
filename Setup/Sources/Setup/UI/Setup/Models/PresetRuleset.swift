import Foundation
import Core

enum PresetRuleset: String, CaseIterable, Sendable {

    case bullet1plus0 = "bullet-1-0"
    case blitz3plus2 = "blitz-3-2"
    case blitz5plus0 = "blitz-5-0"
    case rapid10plus0 = "rapid-10-0"
    case rapid15plus10 = "rapid-15-10"
    case classical90plus30 = "classical-90-30"

    var category: LocalizedStringResource {
        switch self {
        case .bullet1plus0: .bulletCategory
        case .blitz3plus2, .blitz5plus0: .blitzCategory
        case .rapid10plus0, .rapid15plus10: .rapidCategory
        case .classical90plus30: .classicalCategory
        }
    }

    var timeControl: TimeControl {
        switch self {
        case .bullet1plus0: TimeControl(baseMinutes: 1, incrementSeconds: 0)
        case .blitz3plus2: TimeControl(baseMinutes: 3, incrementSeconds: 2)
        case .blitz5plus0: TimeControl(baseMinutes: 5, incrementSeconds: 0)
        case .rapid10plus0: TimeControl(baseMinutes: 10, incrementSeconds: 0)
        case .rapid15plus10: TimeControl(baseMinutes: 15, incrementSeconds: 10)
        case .classical90plus30: TimeControl(baseMinutes: 90, incrementSeconds: 30)
        }
    }

    var description: LocalizedStringResource {
        switch self {
        case .bullet1plus0: .bullet1Plus0Description
        case .blitz3plus2: .blitz3Plus2Description
        case .blitz5plus0: .blitz5Plus0Description
        case .rapid10plus0: .rapid10Plus0Description
        case .rapid15plus10: .rapid15Plus10Description
        case .classical90plus30: .classical90Plus30Description
        }
    }

}
