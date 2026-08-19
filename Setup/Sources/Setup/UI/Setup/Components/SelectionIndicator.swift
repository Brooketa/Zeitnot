import SwiftUI
import CoreUI

struct SelectionIndicator: View {

    let isSelected: Bool

    var body: some View {
        Circle()
            .strokeBorder(borderColor, lineWidth: Constants.ringWidth)
            .background(Circle().fill(fillColor))
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: Constants.checkmarkSize, weight: .bold))
                        .foregroundStyle(ColorPalette.inkInverse)
                }
            }
            .frame(width: Constants.diameter, height: Constants.diameter)
    }

    private var borderColor: Color {
        isSelected ? ColorPalette.accent : ColorPalette.controlBorder
    }

    private var fillColor: Color {
        isSelected ? ColorPalette.accent : .clear
    }

}

private extension SelectionIndicator {

    enum Constants {

        static let diameter: CGFloat = 26
        static let ringWidth: CGFloat = 2
        static let checkmarkSize: CGFloat = 12

    }

}
