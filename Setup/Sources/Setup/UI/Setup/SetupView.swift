import SwiftUI
import CoreUI

public struct SetupView: View {

    @State private var presenter: SetupPresenter

    public init(presenter: SetupPresenter) {
		self.presenter = presenter
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .jumbo) {
                subtitle

                PresetRulesetSection(models: presenter.rulesetModels, action: onPresetRulesetSectionAction)
            }
            .padding(.horizontal, .large)
            .padding(.bottom, .jumbo)
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

    func onPresetRulesetSectionAction(_ action: PresetRulesetSection.Action) {
        switch action {
        case let .select(id): presenter.selectRuleset(id: id)
        }
    }

    func onStartGameBarAction(_ action: StartGameBar.Action) {
        switch action {
        case .start:
            presenter.startGame()
        }
    }

}
