import Observation

@Observable
public final class SetupPresenter {

    private let router: any SetupRoutingProtocol

    private var selection: PresetRuleset = .bullet1plus0

    public init(router: any SetupRoutingProtocol) {
        self.router = router
    }

    public var rulesetModels: [RulesetModel] {
        PresetRuleset.allCases.map { preset in
            RulesetModel(
                id: preset.id,
                category: preset.category,
                baseMinutes: preset.timeControl.baseMinutes,
                incrementSeconds: preset.timeControl.incrementSeconds,
                isSelected: preset == selection)
        }
    }

    public var startGameModel: StartGameModel {
        StartGameModel(
            category: selection.category,
            baseMinutes: selection.timeControl.baseMinutes,
            incrementSeconds: selection.timeControl.incrementSeconds)
    }

    public var gameConfiguration: GameConfiguration {
        GameConfiguration(timeControl: selection.timeControl, category: selection.category)
    }

    public func select(_ ruleset: PresetRuleset) {
        selection = ruleset
    }

    public func selectRuleset(id: String) {
        guard let ruleset = PresetRuleset(rawValue: id) else { return }

        select(ruleset)
    }

    public func startGame() {
        router.navigateToClock(gameConfiguration: gameConfiguration)
    }

}
