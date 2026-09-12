import Foundation
import Shared

nonisolated extension PresetRuleset {

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
