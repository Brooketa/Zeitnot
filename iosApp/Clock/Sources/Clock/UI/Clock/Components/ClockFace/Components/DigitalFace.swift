import SwiftUI
import CoreUI

struct DigitalFace: View {

    let model: Model
    let state: ClockFace.State

    private var appearance: Appearance {
        switch state {
        case .awaitingStart, .waiting: Appearance(color: ColorPalette.textSecondary)
        case .toMove, .lowTime: Appearance(color: ColorPalette.ink)
        case .flagged: Appearance(color: ColorPalette.inkInverse)
        }
    }

    var body: some View {
        Text(model.reading)
            .clockDigits(appearance.color)
    }

}

extension DigitalFace {

    struct Model: Equatable {

        let reading: String

    }

}

private extension DigitalFace {

    struct Appearance {

        let color: Color

    }

}
