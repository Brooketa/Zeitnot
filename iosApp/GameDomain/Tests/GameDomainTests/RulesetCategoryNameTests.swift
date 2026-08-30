import Foundation
import Testing
@testable import GameDomain

struct RulesetCategoryNameTests {

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
