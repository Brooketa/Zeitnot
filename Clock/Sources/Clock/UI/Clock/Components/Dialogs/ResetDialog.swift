import SwiftUI
import CoreUI

struct ResetDialog: View {

    let action: (Action) -> Void

    var body: some View {
        VStack(spacing: .lg) {
            title

            message

            buttons
        }
        .padding(.horizontal, .xxl)
        .alignCenter()
    }

    var title: some View {
        Text(.resetDialogTitle)
            .largeTitle()
            .textCase(.uppercase)
    }

    var message: some View {
        Text(.resetDialogMessage)
            .callout(ColorPalette.textSecondary)
    }

    var buttons: some View {
        HStack(spacing: .md) {
            button(for: .cancel, title: .cancelButton, background: ColorPalette.surface, label: ColorPalette.ink)

            button(
                for: .confirm,
                title: .confirmResetButton,
                background: ColorPalette.accent,
                label: ColorPalette.inkInverse)
        }
    }

    func button(
        for control: Action,
        title: LocalizedStringResource,
        background: Color,
        label: Color
    ) -> some View {
        Button {
            action(control)
        } label: {
            Text(title)
                .buttonLabel(label)
                .textCase(.uppercase)
                .padding(.horizontal, .xl)
                .padding(.vertical, .md)
                .background(background)
                .clipShape(.capsule)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
		.padding(.top, .sm)
    }

}

extension ResetDialog {

    enum Action {

        case confirm
        case cancel

    }

}
