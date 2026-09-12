import SwiftUI

public extension View {

    // MARK: Sizing

    func maxWidth(_ maxWidth: CGFloat = .infinity) -> some View {
        frame(maxWidth: maxWidth)
    }

    func maxHeight(_ maxHeight: CGFloat = .infinity) -> some View {
        frame(maxHeight: maxHeight)
    }

    func maxSize(maxWidth: CGFloat = .infinity, maxHeight: CGFloat = .infinity) -> some View {
        frame(maxWidth: maxWidth, maxHeight: maxHeight)
    }

    // MARK: Background

    func primaryBackground() -> some View {
        background {
            ColorPalette.background.ignoresSafeArea()
        }
    }

    // MARK: Alignment

    func alignCenter() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    func alignCenterHorizontal() -> some View {
        frame(maxWidth: .infinity, alignment: .center)
    }

    func alignCenterVertical() -> some View {
        frame(maxHeight: .infinity, alignment: .center)
    }

    func alignLeading() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }

    func alignTrailing() -> some View {
        frame(maxWidth: .infinity, alignment: .trailing)
    }

    func alignTop() -> some View {
        frame(maxHeight: .infinity, alignment: .top)
    }

    func alignBottom() -> some View {
        frame(maxHeight: .infinity, alignment: .bottom)
    }

    func alignTopLeading() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    func alignTopTrailing() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    func alignBottomLeading() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    func alignBottomTrailing() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    // MARK: Miscellaneous

    func enabled(_ isEnabled: Bool) -> some View {
        disabled(!isEnabled)
    }

}
