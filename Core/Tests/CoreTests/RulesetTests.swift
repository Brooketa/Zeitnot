import Testing
import Core

struct RulesetTests {

    @Test
    func rulesetCarriesCategoryAndTimeControl() {
        let ruleset = Ruleset(category: .blitz, timeControl: TimeControl(baseMinutes: 3, incrementSeconds: 2))

        #expect(ruleset.category == .blitz)
        #expect(ruleset.timeControl.baseMinutes == 3)
        #expect(ruleset.timeControl.incrementSeconds == 2)
    }

    @Test
    func presetRulesetIsNotCustom() {
        let ruleset = Ruleset(category: .classical, timeControl: TimeControl(baseMinutes: 90, incrementSeconds: 30))

        #expect(ruleset.isCustom == false)
    }

    @Test
    func customRulesetIsCustom() {
        let ruleset = Ruleset(category: .custom, timeControl: TimeControl(baseMinutes: 5, incrementSeconds: 3))

        #expect(ruleset.isCustom)
    }

}
