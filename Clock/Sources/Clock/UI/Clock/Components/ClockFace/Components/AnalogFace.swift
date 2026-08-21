import SwiftUI
import CoreUI

struct AnalogFace: View {

    let model: Model
    let state: ClockFace.State

    private var appearance: Appearance {
        switch state {
        case .awaitingStart, .waiting:
            Appearance(
                face: ColorPalette.textSecondary,
                minuteHand: ColorPalette.textSecondary,
                secondHand: ColorPalette.textSecondary)
        case .toMove, .lowTime:
            Appearance(
                face: ColorPalette.ink,
                minuteHand: ColorPalette.ink,
                secondHand: ColorPalette.accent)
        case .flagged:
            Appearance(
                face: ColorPalette.inkInverse,
                minuteHand: ColorPalette.inkInverse,
                secondHand: ColorPalette.inkInverse)
        }
    }

    var body: some View {
        ZStack {
            layer(Image.face, color: appearance.face)

            layer(Image.secondHand, color: appearance.secondHand)
                .rotationEffect(.degrees(-model.hands.secondDegrees))

            layer(Image.minuteHand, color: appearance.minuteHand)
                .rotationEffect(.degrees(-model.hands.minuteDegrees))
        }
    }

    func layer(_ image: Image, color: Color) -> some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
    }

}

extension AnalogFace {

    struct Model: Equatable {

        let hands: DialHands

    }

}

private extension AnalogFace {

    struct Appearance {

        let face: Color
        let minuteHand: Color
        let secondHand: Color

    }

}
