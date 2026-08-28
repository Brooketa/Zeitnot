import SwiftUI
import CoreUI

struct CardDivider: View {

    var body: some View {
        Rectangle()
            .fill(ColorPalette.separator)
            .frame(height: Constants.thickness)
    }

}

private extension CardDivider {

    enum Constants {

        static let thickness: CGFloat = 1

    }

}
