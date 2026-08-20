import Observation
import Core

@Observable
public final class SetupPresenter {

    var rulesetModels: [RulesetCell.Model] {
        PresetRuleset.catalogue.map { preset in
            RulesetCell.Model(
                id: preset.id,
                category: preset.category,
                description: preset.description,
                baseMinutes: preset.timeControl.baseMinutes,
                incrementSeconds: preset.timeControl.incrementSeconds,
                isSelected: preset.id == selection.id)
        }
    }

    var startGameModel: StartGameBar.Model {
        StartGameBar.Model(
            category: selectedCategory,
            baseMinutes: selection.timeControl.baseMinutes,
            incrementSeconds: selection.timeControl.incrementSeconds)
    }

    var gameConfiguration: GameConfiguration {
        GameConfiguration(timeControl: selection.timeControl, category: selectedCategory)
    }

    private let router: SetupRoutingProtocol

    private var selection: PresetRuleset = .bullet1plus0

    private var selectedCategory: String {
        String(localized: selection.category)
    }

    public init(router: SetupRoutingProtocol) {
        self.router = router
    }

    func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

    func selectRuleset(id: String) {
        guard let preset = PresetRuleset.catalogue.first(where: { preset in preset.id == id }) else { return }

        select(preset)
    }

    func startGame() {
        router.navigateToClock(gameConfiguration: gameConfiguration)
    }

}
