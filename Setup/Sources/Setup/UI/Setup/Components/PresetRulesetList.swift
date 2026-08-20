import SwiftUI

struct PresetRulesetList: View {

    let models: [RulesetCell.Model]
    let action: (Action) -> Void

    var body: some View {
        SectionCard {
            ForEach(models) { model in
                RulesetCell(model: model) { action in
                    onRulesetCellAction(action, for: model)
                }

                if model.id != models.last?.id {
                    CardDivider()
                }
            }
        }
    }

}

extension PresetRulesetList {

    enum Action {

        case select(id: String)

    }

}

private extension PresetRulesetList {

    func onRulesetCellAction(_ action: RulesetCell.Action, for model: RulesetCell.Model) {
        switch action {
        case .select: self.action(.select(id: model.id))
        }
    }

}
