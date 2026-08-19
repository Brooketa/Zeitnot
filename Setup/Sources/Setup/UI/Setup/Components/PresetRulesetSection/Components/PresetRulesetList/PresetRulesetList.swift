import SwiftUI

struct PresetRulesetList: View {

    let models: [RulesetCell.Model]
    let action: (PresetRuleset) -> Void

    var body: some View {
        SectionCard {
            ForEach(models) { model in
                RulesetCell(model: model) { cellAction in
                    handle(cellAction, for: model)
                }

                if model.id != models.last?.id {
                    CardDivider()
                }
            }
        }
    }

}

private extension PresetRulesetList {

    func handle(_ cellAction: RulesetCell.Action, for model: RulesetCell.Model) {
        switch cellAction {
        case .select:
            action(model.ruleset)
        }
    }

}
