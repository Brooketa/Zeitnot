import SwiftUI
import CoreUI

public struct SetupView: View {

    @State private var presenter = SetupPresenter()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .xxl) {
                subtitle

                PresetRulesetSection(models: presenter.rulesetModels, action: onPresetRulesetSelected)
            }
            .padding(.horizontal, .lg)
            .padding(.bottom, .xxl)
        }
        .background(ColorPalette.background)
        .navigationTitle(Text(.setTheClocks))
        .navigationBarTitleDisplayMode(.large)
        .safeAreaBar(edge: .bottom) {
            StartGameBar(model: presenter.startGameModel, action: onStartGameBarAction)
        }
    }

    var subtitle: some View {
		Text(.chooseARuleset)
            .callout()
    }

}

private extension SetupView {

    func onPresetRulesetSelected(_ ruleset: PresetRuleset) {
        presenter.select(ruleset)
    }

    func onStartGameBarAction(_ action: StartGameBar.Action) {
        switch action {
        case .start:
            presenter.startGame()
        }
    }

}
