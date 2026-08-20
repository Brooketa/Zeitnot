import Foundation
import Observation
import Core

@Observable
final class SetupPresenter {

    var rulesetModels: [RulesetCell.Model] {
        PresetRuleset.allCases.map { preset in
            RulesetCell.Model(ruleset: preset, isSelected: preset == selection)
        }
    }

    var startGameModel: StartGameBar.Model {
        StartGameBar.Model(category: selectedCategory, timeControl: selection.timeControl)
    }

    var gameConfiguration: GameConfiguration {
        GameConfiguration(timeControl: selection.timeControl, category: selectedCategory)
    }

    private var selection: PresetRuleset = .blitz3plus2

    private var selectedCategory: String {
        String(localized: selection.category)
    }

    func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

    func startGame() {}

}
