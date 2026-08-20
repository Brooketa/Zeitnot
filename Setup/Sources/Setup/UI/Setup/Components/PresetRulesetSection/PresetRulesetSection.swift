import SwiftUI
import CoreUI

struct PresetRulesetSection: View {

    let models: [RulesetCell.Model]
    let action: (PresetRuleset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .md) {
            SectionHeader(title: .presetRulesets)

            PresetRulesetList(models: models, action: action)
        }
    }

}
