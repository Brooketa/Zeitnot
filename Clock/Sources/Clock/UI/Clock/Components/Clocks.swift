import SwiftUI
import CoreUI

struct Clocks: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        HStack(spacing: .large) {
            ClockFace(model: model.white, action: onClockFaceAction)

            ClockFace(model: model.black, action: onClockFaceAction)
        }
    }

}

extension Clocks {

    struct Model {

        let white: ClockFace.Model
        let black: ClockFace.Model

    }

    enum Action {

        case press(ClockFace.Side)

    }

}

private extension Clocks {

    func onClockFaceAction(_ clockFaceAction: ClockFace.Action) {
        switch clockFaceAction {
        case let .press(side): action(.press(side))
        }
    }

}
