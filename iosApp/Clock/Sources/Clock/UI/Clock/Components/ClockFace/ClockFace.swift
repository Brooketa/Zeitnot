import SwiftUI
import CoreUI
import Shared

struct ClockFace: View {

    let model: Model
    let action: (Action) -> Void

    private var appearance: State.Appearance {
        model.state.appearance
    }

    private var caption: LocalizedStringResource? {
        model.state.caption(side: model.side)
    }

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
        VStack(spacing: .small) {
            Text(model.side.name)
                .playerName(appearance.name)
                .textCase(.uppercase)
                .padding(.top, .small)

            timeDisplay

            captionText
                .micro(appearance.caption)
                .textCase(.uppercase)
                .opacity(caption == nil ? 0 : 1)
                .padding(.bottom, .small)
        }
    }

    var captionText: Text {
        guard let caption else { return Text(verbatim: Constants.captionPlaceholder) }

        return Text(caption)
    }

    @ViewBuilder
    var timeDisplay: some View {
        switch model.timeDisplay {
        case let .digital(digital): DigitalFace(model: digital, state: model.state)
        case let .analog(analog): AnalogFace(model: analog, state: model.state)
        }
    }

    var cardShape: RoundedRectangle {
        .rect(cornerRadius: Constants.cornerRadius, style: .continuous)
    }

    var turnRing: some View {
        cardShape
            .strokeBorder(ColorPalette.accent, lineWidth: Constants.turnRingWidth)
            .phaseAnimator(appearance.ring.phases) { content, phase in
                content.opacity(phase.opacity)
            } animation: { _ in
                .easeInOut(duration: Constants.pulseDuration)
            }
    }

}

extension ClockFace {

    typealias Model = ClockFaceModel
    typealias Side = ClockFaceSide
    typealias State = ClockFaceState
    typealias TimeDisplay = ClockFaceTimeDisplay

    enum Action {

        case press(Side)

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

    enum RingPhase {

        case hidden
        case shown
        case dimmed

        var opacity: CGFloat {
            switch self {
            case .hidden: 0
            case .shown: 1
            case .dimmed: Constants.pulseOpacity
            }
        }

    }

}

private extension ClockFace.Side {

    var name: LocalizedStringResource {
        switch self {
        case .white: .whitePlayer
        case .black: .blackPlayer
        }
    }

}

private extension ClockFace.State {

    struct Appearance {

        let fill: Color
        let name: Color
        let caption: Color
        let ring: Ring

    }

    enum Ring {

        case none
        case steady
        case pulsing

        var phases: [ClockFace.RingPhase] {
            switch self {
            case .none: [.hidden]
            case .steady: [.shown]
            case .pulsing: [.shown, .dimmed]
            }
        }

    }

}

private extension ClockFace.State {

    var appearance: Appearance {
        switch self {
        case .awaitingStart, .waiting:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.textSecondary,
                caption: ColorPalette.accent,
                ring: .none)
        case .toMove:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.accent,
                caption: ColorPalette.accent,
                ring: .steady)
        case .lowTime:
            Appearance(
                fill: ColorPalette.surface,
                name: ColorPalette.accent,
                caption: ColorPalette.accent,
                ring: .pulsing)
        case .flagged:
            Appearance(
                fill: ColorPalette.accent,
                name: ColorPalette.inkInverse,
                caption: ColorPalette.inkInverse,
                ring: .none)
        }
    }

    func caption(side: ClockFace.Side) -> LocalizedStringResource? {
        switch self {
        case .flagged: .flagFell
        case .awaitingStart where side == .black: .pressToStart
        default: nil
        }
    }

}
