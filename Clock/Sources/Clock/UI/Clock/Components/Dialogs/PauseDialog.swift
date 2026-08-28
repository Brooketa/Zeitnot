import SwiftUI
import CoreUI

struct PauseDialog: View {

    let model: Model
    let action: (Action) -> Void

    var body: some View {
        VStack(spacing: .large) {
            title

            playerToMove

            resumeButton
        }
        .alignCenter()
    }

    var title: some View {
        Text(.pausedTitle)
            .largeTitle()
            .textCase(.uppercase)
    }

    var playerToMove: some View {
        Text(model.playerToMove.text)
            .callout(ColorPalette.textSecondary)
            .textCase(.uppercase)
    }

    var resumeButton: some View {
        Button {
            action(.resume)
        } label: {
            Text(.resumeButton)
                .buttonLabel(ColorPalette.inkInverse)
                .textCase(.uppercase)
                .padding(.horizontal, .jumbo)
                .padding(.vertical, .medium)
                .background(ColorPalette.accent)
                .clipShape(.capsule)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
		.padding(.top, .small)
    }

}

extension PauseDialog {

    struct Model {

        let playerToMove: Player

    }

    enum Player {

        case white
        case black

    }

}

extension PauseDialog {

    enum Action {

        case resume

    }

}

private extension PauseDialog.Player {

    var text: LocalizedStringResource {
        switch self {
        case .white: .whiteToMove
        case .black: .blackToMove
        }
    }

}
