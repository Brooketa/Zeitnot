import SwiftUI
import CoreUI
import Shared

struct ControlBar: View {

    let model: Model
    let action: (Action) -> Void

    @Binding var displayMode: DisplayMode

    var body: some View {
        HStack(spacing: .medium) {
            DisplayModeControl(displayMode: $displayMode)

            button(for: .pause, title: .pauseButton)
                .enabled(model.canPause)
                .opacity(model.canPause ? 1 : Constants.disabledOpacity)

            button(for: .reset, title: .resetButton)
                .enabled(model.canReset)
                .opacity(model.canReset ? 1 : Constants.disabledOpacity)
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
                .padding(.horizontal, .extraLarge)
                .padding(.vertical, .medium)
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

    typealias Model = ControlBarModel

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
