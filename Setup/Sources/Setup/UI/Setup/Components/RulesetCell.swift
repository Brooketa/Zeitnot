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

    private var content: some View {
        HStack(spacing: .lg) {
            VStack(alignment: .leading, spacing: .xs) {
                Text(model.category)
                    .micro()
                    .textCase(.uppercase)

                Text(model.timeControl)
                    .title()

                Text(model.description)
                    .footnote()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SelectionIndicator(isSelected: model.isSelected)
        }
        .padding(.lg)
        .contentShape(.rect)
    }

}

extension RulesetCell {

    struct Model {

        let category: String
        let timeControl: String
        let description: String
        let isSelected: Bool

    }

}

extension RulesetCell {

    enum Action {

        case select

    }

}
