import SwiftUI
import CoreUI

struct ClockFace: View {

    let model: Model
    let action: (Action) -> Void

	private var appearance: State.Appearance {
		model.state.appearance
	}

	private var pulseAnimation: Animation? {
		guard isPulsing else { return nil }

		return .easeInOut(duration: Constants.pulseDuration).repeatForever(autoreverses: true)
	}

    @SwiftUI.State private var isPulsing = false

    var body: some View {
        content
            .alignCenter()
            .background(appearance.fill)
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
                .playerName(appearance.name)
                .textCase(.uppercase)

            Text(model.time)
                .clockDigits(appearance.digits)

			Text(model.caption ?? Constants.captionPlaceholder)
				.micro(appearance.caption)
				.textCase(.uppercase)
				.opacity(model.caption == nil ? 0 : 1)
        }
    }

    var cardShape: RoundedRectangle {
        .rect(cornerRadius: Constants.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    var turnRing: some View {
        if appearance.ring != .none {
            cardShape
                .strokeBorder(ColorPalette.accent, lineWidth: Constants.turnRingWidth)
                .opacity(isPulsing ? Constants.pulseOpacity : 1)
                .animation(pulseAnimation, value: isPulsing)
                .task(id: model.state) {
                    isPulsing = appearance.ring == .pulsing
                }
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

	enum Side {

		case white
		case black

	}

	enum State {

		case awaitingStart
		case toMove
		case lowTime
		case waiting
		case flagged

	}

	enum Action {

		case press(Side)

	}

}

private extension ClockFace.State {

    var appearance: Appearance {
        switch self {
        case .awaitingStart, .waiting:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.textSecondary,
                digits: ColorPalette.textSecondary,
                caption: ColorPalette.accent,
                ring: .none)
        case .toMove:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.accent,
                digits: ColorPalette.ink,
                caption: ColorPalette.accent,
                ring: .steady)
        case .lowTime:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.accent,
                digits: ColorPalette.ink,
                caption: ColorPalette.accent,
                ring: .pulsing)
        case .flagged:
            Appearance(
                fill: ColorPalette.accent,
                name: ColorPalette.inkInverse,
                digits: ColorPalette.inkInverse,
                caption: ColorPalette.inkInverse,
                ring: .none)
        }
    }

}

private extension ClockFace.State {

    struct Appearance {

        let fill: Color
        let name: Color
        let digits: Color
        let caption: Color
        let ring: Ring

    }

}

private extension ClockFace.State {

    enum Ring {

        case none
        case steady
        case pulsing

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
        static let pulseDuration: TimeInterval = 0.5
        static let pulseOpacity: CGFloat = 0.25

    }

}
