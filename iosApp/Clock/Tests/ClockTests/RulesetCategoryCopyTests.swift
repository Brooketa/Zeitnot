import Foundation
import Testing
import Shared
@testable import Clock

struct RulesetCategoryCopyTests {

    @Test(arguments: [
        (category: RulesetCategory.bullet, name: "Bullet"),
        (category: RulesetCategory.blitz, name: "Blitz"),
        (category: RulesetCategory.rapid, name: "Rapid"),
        (category: RulesetCategory.classical, name: "Classical")
    ])
    func everyCategoryIsNamedInNaturalCasing(category: RulesetCategory, name: String) {
        #expect(String(localized: category.name) == name)
    }

}
