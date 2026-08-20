import SwiftUI
import CoreUI

struct Header: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        ZStack {
            ruleset

            backButton
                .alignLeading()

            moveNumber
                .alignTrailing()
        }
        .frame(height: Constants.height)
    }

    var backButton: some View {
        Button {
            action(.back)
        } label: {
            Image.back
                .font(.system(size: Constants.chevronSize, weight: .semibold))
                .foregroundStyle(ColorPalette.ink)
                .frame(width: Constants.backDiameter, height: Constants.backDiameter)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(Text(.backButton))
    }

    var ruleset: some View {
        HStack(spacing: .small) {
            Circle()
                .fill(model.isRunning ? ColorPalette.accent : ColorPalette.textTertiary)
                .frame(width: Constants.dotDiameter, height: Constants.dotDiameter)
                .animation(.easeOut(duration: Constants.dotDuration), value: model.isRunning)

            Text(.rulesetTitle(model.category, model.baseMinutes, model.incrementSeconds))
                .label(ColorPalette.ink)
                .textCase(.uppercase)
        }
    }

    var moveNumber: some View {
        Text(.moveNumber(model.moveNumber))
            .label(ColorPalette.textSecondary)
            .textCase(.uppercase)
    }

}

extension Header {

    struct Model {

        let category: String
        let baseMinutes: Int
        let incrementSeconds: Int
        let moveNumber: Int
        let isRunning: Bool

    }

}

extension Header {

    enum Action {

        case back

    }

}

private extension Header {

    enum Constants {

        static let height: CGFloat = 44
        static let backDiameter: CGFloat = 44
        static let chevronSize: CGFloat = 20
        static let dotDiameter: CGFloat = 7
        static let dotDuration: TimeInterval = 0.2

    }

}
