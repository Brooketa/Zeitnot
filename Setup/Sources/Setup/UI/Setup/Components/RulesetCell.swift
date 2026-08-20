import SwiftUI
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
        .padding(.lg)
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

}

extension RulesetCell {

    enum Action {

        case select

    }

}
