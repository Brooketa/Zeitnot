import SwiftUI
import Core
import CoreUI

struct ClockFace: View {

    let model: Model

    var body: some View {
        content
            .alignCenter()
            .background(ColorPalette.surface)
            .clipShape(cardShape)
            .overlay {
                turnRing
            }
            .shadow(
                color: ColorPalette.ink.opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius,
                y: Constants.shadowOffset)
            .animation(.easeOut(duration: Constants.stateChangeDuration), value: model.state)
    }

	var content: some View {
		VStack(spacing: .sm) {
			Text(model.player)
				.playerName(model.state.nameColor)
				.textCase(.uppercase)

			Text(model.time)
				.clockDigits(model.state.digitsColor)
		}
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

        let player: String
        let time: String
        let state: State

    }

}

extension ClockFace {

    enum State {

        case awaitingStart
        case toMove
        case waiting

    }

}

private extension ClockFace.State {

    var digitsColor: Color {
        switch self {
        case .awaitingStart, .waiting: ColorPalette.textSecondary
        case .toMove: ColorPalette.ink
        }
    }

    var nameColor: Color {
        switch self {
        case .awaitingStart, .waiting: ColorPalette.textSecondary
        case .toMove: ColorPalette.accent
        }
    }

    var showsTurnRing: Bool {
        self == .toMove
    }

}

private extension ClockFace {

    enum Constants {

        static let cornerRadius: CGFloat = 26
        static let turnRingWidth: CGFloat = 3
        static let shadowRadius: CGFloat = 3
        static let shadowOffset: CGFloat = 1
        static let shadowOpacity: CGFloat = 0.12
        static let stateChangeDuration: TimeInterval = 0.2

    }

}
