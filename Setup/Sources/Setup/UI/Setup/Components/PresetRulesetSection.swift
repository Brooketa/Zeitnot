import SwiftUI
import CoreUI

struct PresetRulesetSection: View {

    let models: [RulesetCell.Model]
    let action: (Action) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            SectionHeader(title: .presetRulesets)

            PresetRulesetList(models: models, action: onPresetRulesetListAction)
        }
    }

}

extension PresetRulesetSection {

    enum Action {

        case select(id: String)

    }

}

private extension PresetRulesetSection {

    func onPresetRulesetListAction(_ action: PresetRulesetList.Action) {
        switch action {
        case let .select(id): self.action(.select(id: id))
        }
    }

}
