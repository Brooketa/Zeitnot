import SwiftUI
import Core
import CoreUI

struct RulesetCell: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        Button {
            action(.select)
        } label: {
            content
        }
        .buttonStyle(.plain)
    }

}

private extension RulesetCell {

    var content: some View {
        HStack(spacing: .lg) {
            VStack(alignment: .leading, spacing: .xs) {
                Text(model.ruleset.category)
                    .micro()
                    .textCase(.uppercase)

                Text(timeControlNotation)
                    .title()

                Text(model.ruleset.description)
                    .callout()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SelectionIndicator(isSelected: model.isSelected)
        }
        .padding(.lg)
        .contentShape(.rect)
    }

    var timeControlNotation: String {
        let timeControl = model.ruleset.timeControl

        return "\(timeControl.baseMinutes) | \(timeControl.incrementSeconds)"
    }

}

extension RulesetCell {

    struct Model: Identifiable {

        let ruleset: PresetRuleset
        let isSelected: Bool

        var id: String {
			ruleset.rawValue
        }

    }

}

extension RulesetCell {

    enum Action {

        case select

    }

}
