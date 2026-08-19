import SwiftUI
import CoreUI

public struct SetupView: View {

    @State private var presenter = SetupPresenter()

    public init() {}

    public var body: some View {
        ScrollView {
            PresetRulesetList(models: presenter.rulesetModels, action: onPresetRulesetListAction)
                .padding(.lg)
        }
        .background(ColorPalette.background)
    }

}

private extension SetupView {

    func onPresetRulesetListAction(_ ruleset: PresetRuleset) {
        presenter.select(ruleset)
    }

}
