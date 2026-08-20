import SwiftUI
import CoreUI

struct PresetRulesetSection: View {

    let models: [RulesetCell.Model]
    let action: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .md) {
            SectionHeader(title: .presetRulesets)

            PresetRulesetList(models: models, action: onPresetRulesetListAction)
        }
    }

}

extension PresetRulesetSection {

    enum Action {

        case select(PresetRuleset)

    }

}

private extension PresetRulesetSection {

    func onPresetRulesetListAction(_ action: PresetRulesetList.Action) {
        switch action {
		case let .select(ruleset): self.action(.select(ruleset))
        }
    }

}
