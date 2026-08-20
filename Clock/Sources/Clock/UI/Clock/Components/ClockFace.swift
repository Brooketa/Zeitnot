import SwiftUI
import Core
import CoreUI

struct ClockFace: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        content
            .alignCenter()
            .background(model.state.fill)
            .clipShape(cardShape)
            .overlay {
                turnRing
            }
            .shadow(
                color: ColorPalette.ink.opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius,
                y: Constants.shadowOffset)
            .contentShape(.rect)
            .onTapGesture {
                action(.press(model.side))
            }
            .animation(.easeOut(duration: Constants.stateChangeDuration), value: model.state)
    }

    var content: some View {
        VStack(spacing: .sm) {
            Text(model.name)
                .playerName(model.state.nameColor)
                .textCase(.uppercase)

            Text(model.time)
                .clockDigits(model.state.digitsColor)

            caption
        }
    }

    var caption: some View {
        Text(model.caption ?? Constants.captionPlaceholder)
            .micro(model.state.captionColor)
            .textCase(.uppercase)
            .opacity(model.caption == nil ? 0 : 1)
    }

    var cardShape: RoundedRectangle {
        .rect(cornerRadius: Constants.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    var turnRing: some View {
        if model.state.showsTurnRing {
            cardShape
                .strokeBorder(ColorPalette.accent, lineWidth: Constants.turnRingWidth)
        }
    }

}

extension ClockFace {

    struct Model {

        let side: Side
        let name: String
        let time: String
        let caption: String?
        let state: State

    }

}

extension ClockFace {

    enum Side {

        case white
        case black

    }

}

extension ClockFace {

    enum Action {

        case press(Side)

    }

}

extension ClockFace {

    enum State {

        case awaitingStart
        case toMove
        case waiting
        case flagged

    }

}

private extension ClockFace.State {

    var fill: Color {
        switch self {
        case .awaitingStart, .toMove, .waiting: ColorPalette.surface
        case .flagged: ColorPalette.accent
        }
    }

    var digitsColor: Color {
        switch self {
        case .awaitingStart, .waiting: ColorPalette.textSecondary
        case .toMove: ColorPalette.ink
        case .flagged: ColorPalette.inkInverse
        }
    }

    var nameColor: Color {
        switch self {
        case .awaitingStart, .waiting: ColorPalette.textSecondary
        case .toMove: ColorPalette.accent
        case .flagged: ColorPalette.inkInverse
        }
    }

    var captionColor: Color {
        switch self {
        case .awaitingStart, .toMove, .waiting: ColorPalette.accent
        case .flagged: ColorPalette.inkInverse
        }
    }

    var showsTurnRing: Bool {
        self == .toMove
    }

}

private extension ClockFace {

    enum Constants {

        static let captionPlaceholder = " "

        static let cornerRadius: CGFloat = 26
        static let turnRingWidth: CGFloat = 3
        static let shadowRadius: CGFloat = 3
        static let shadowOffset: CGFloat = 1
        static let shadowOpacity: CGFloat = 0.12
        static let stateChangeDuration: TimeInterval = 0.2

    }

}
