import SwiftUI
import CoreUI

struct DisplayModeControl: View {

    let model: Model
    let action: (Action) -> Void

    @Namespace private var namespace
    @State private var selection: DisplayMode?

    private var selected: DisplayMode {
        selection ?? model.displayMode
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DisplayMode.allCases, id: \.self) { mode in
                segment(for: mode)
            }
        }
        .padding(Constants.trackPadding)
        .background(ColorPalette.surfaceMuted)
        .clipShape(.capsule)
        .task(id: model.displayMode) {
            selection = model.displayMode
        }
    }

    func segment(for mode: DisplayMode) -> some View {
        let isSelected = mode == selected

        return Button {
            withAnimation(.snappy(duration: Constants.selectionDuration)) {
                selection = mode
            }

            action(.select(mode))
        } label: {
            Text(title(for: mode))
                .label(isSelected ? ColorPalette.inkInverse : ColorPalette.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, .medium)
                .padding(.vertical, .small)
                .background {
                    if isSelected {
                        selectionHighlight
                    }
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    var selectionHighlight: some View {
        Capsule()
            .fill(ColorPalette.ink)
            .matchedGeometryEffect(id: Constants.selectionId, in: namespace)
    }

    func title(for mode: DisplayMode) -> LocalizedStringResource {
        switch mode {
        case .digital: .digitalMode
        case .analog: .analogMode
        }
    }

}

extension DisplayModeControl {

    struct Model {

        let displayMode: DisplayMode

    }

    enum Action {

        case select(DisplayMode)

    }

}

private extension DisplayModeControl {

    enum Constants {

        static let selectionId = "displayModeSelection"

        static let trackPadding: CGFloat = .extraSmall
        static let selectionDuration: TimeInterval = 0.2

    }

}
