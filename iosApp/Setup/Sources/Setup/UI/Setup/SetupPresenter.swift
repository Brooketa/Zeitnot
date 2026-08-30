import Observation
import GameDomain

@Observable
public final class SetupPresenter {

    private let router: SetupRoutingProtocol

    private var selection: PresetRuleset = .bullet1plus0

    public init(router: SetupRoutingProtocol) {
        self.router = router
    }

    var rulesetModels: [RulesetCell.Model] {
        PresetRuleset.allCases.map { preset in
            RulesetCell.Model(
                id: preset.id,
                category: preset.category.name,
                description: preset.description,
                baseMinutes: preset.timeControl.baseMinutes,
                incrementSeconds: preset.timeControl.incrementSeconds,
                isSelected: preset == selection)
        }
    }

    var startGameModel: StartGameBar.Model {
        StartGameBar.Model(
            category: selection.category.name,
            baseMinutes: selection.timeControl.baseMinutes,
            incrementSeconds: selection.timeControl.incrementSeconds)
    }

    var gameConfiguration: GameConfiguration {
        GameConfiguration(timeControl: selection.timeControl, category: selection.category)
    }

    func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

    func selectRuleset(id: String) {
        guard let ruleset = PresetRuleset(rawValue: id) else { return }

        select(ruleset)
    }

    func startGame() {
        router.navigateToClock(gameConfiguration: gameConfiguration)
    }

}
