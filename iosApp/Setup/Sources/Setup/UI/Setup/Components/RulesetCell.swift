import SwiftUI
import CoreUI
import Shared

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
        HStack(spacing: .large) {
            VStack(alignment: .leading, spacing: .extraSmall) {
                Text(model.category)
                    .micro()
                    .textCase(.uppercase)

                timeControlNotation

                Text(model.description)
                    .callout()
            }
            .alignLeading()

            SelectionIndicator(isSelected: model.isSelected)
        }
        .padding(.large)
        .contentShape(.rect)
    }

    var timeControlNotation: Text {
        Text(.timeControlNotation(model.baseMinutes, model.incrementSeconds))
            .title()
    }

}

extension RulesetCell {

    struct Model: Identifiable {

        let id: String
        let category: LocalizedStringResource
        let description: LocalizedStringResource
        let baseMinutes: Int
        let incrementSeconds: Int
        let isSelected: Bool

    }

	enum Action {

		case select

	}

}

extension RulesetCell.Model {

    init?(_ ruleset: RulesetModel) {
        guard let preset = PresetRuleset(rawValue: ruleset.id) else { return nil }

        self.init(
            id: ruleset.id,
            category: ruleset.category.name,
            description: preset.description,
            baseMinutes: ruleset.baseMinutes,
            incrementSeconds: ruleset.incrementSeconds,
            isSelected: ruleset.isSelected)
    }

}
