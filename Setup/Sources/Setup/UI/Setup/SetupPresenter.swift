import Observation
import Core

@Observable
final class SetupPresenter {

    private var selection: PresetRuleset = .blitz3plus2

    var rulesetModels: [RulesetCell.Model] {
        PresetRuleset.allCases.map { preset in
            RulesetCell.Model(ruleset: preset, isSelected: preset == selection)
        }
    }

    var selectedRulesetName: String {
        "\(selection.category) \(selection.timeControl.baseMinutes) | \(selection.timeControl.incrementSeconds)"
    }

    var gameConfiguration: GameConfiguration {
        GameConfiguration(timeControl: selection.timeControl, category: selection.category)
    }

    func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

    func startGame() {}

}