import Observation

@Observable
final class SetupPresenter {

    private var selection: PresetRuleset = .blitz3plus2

    var rulesetModels: [RulesetCell.Model] {
        PresetRuleset.allCases.map { preset in
            RulesetCell.Model(ruleset: preset, isSelected: preset == selection)
        }
    }

    func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

}
