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
        .navigationTitle(Constants.title)
        .navigationBarTitleDisplayMode(.large)
    }

	var subtitle: some View {
		Text(Constants.subtitle)
			.callout()
	}

}

private extension SetupView {

    func onPresetRulesetSelected(_ ruleset: PresetRuleset) {
        presenter.select(ruleset)
    }

}

private extension SetupView {

    enum Constants {

        static var title: String { "Chess Clock" }
        static var subtitle: String { "Choose how long you want to play." }

    }

}
