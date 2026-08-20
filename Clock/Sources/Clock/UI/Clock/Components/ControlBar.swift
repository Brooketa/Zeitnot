import SwiftUI
import CoreUI

struct ControlBar: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        HStack(spacing: .md) {
            button(for: .pause, title: .pauseButton)
                .enabled(model.canPause)
                .opacity(model.canPause ? 1 : Constants.disabledOpacity)

            button(for: .reset, title: .resetButton)
        }
        .alignCenterHorizontal()
    }

    func button(for control: Action, title: LocalizedStringResource) -> some View {
        Button {
            action(control)
        } label: {
            Text(title)
                .buttonLabel(ColorPalette.ink)
                .textCase(.uppercase)
                .padding(.horizontal, .xl)
                .padding(.vertical, .md)
                .background(ColorPalette.surface)
                .clipShape(.capsule)
                .overlay {
                    Capsule().strokeBorder(ColorPalette.controlBorder)
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

}

extension ControlBar {

    struct Model {

        let canPause: Bool

    }

}

extension ControlBar {

    enum Action {

        case pause
        case reset

    }

}

private extension ControlBar {

    enum Constants {

        static let disabledOpacity: CGFloat = 0.4

    }

}
