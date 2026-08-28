import SwiftUI
import CoreUI

struct SectionCard<Content: View>: View {

    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(ColorPalette.surface)
        .clipShape(.rect(cornerRadius: Constants.cornerRadius))
    }

}

private enum Constants {

    static let cornerRadius: CGFloat = 16

}
