import Foundation
import Shared

extension RulesetCategory {

    var name: LocalizedStringResource {
        switch self {
        case .bullet: .bulletCategory
        case .blitz: .blitzCategory
        case .rapid: .rapidCategory
        case .classical: .classicalCategory
        }
    }

}
