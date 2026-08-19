import Testing
import Core

struct RulesetCategoryTests {

    @Test(arguments: [
        (category: RulesetCategory.bullet, title: "Bullet"),
        (category: RulesetCategory.blitz, title: "Blitz"),
        (category: RulesetCategory.rapid, title: "Rapid"),
        (category: RulesetCategory.classical, title: "Classical"),
        (category: RulesetCategory.custom, title: "Custom")
    ])
    func everyCategoryHasItsTitle(category: RulesetCategory, title: String) {
        #expect(category.title == title)
    }

    @Test
    func everyCategoryIsCovered() {
        #expect(RulesetCategory.allCases.count == 5)
    }

}
