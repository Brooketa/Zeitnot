import SwiftUI

public extension View {

    func presentFullScreen(if isPresented: Bool, @ViewBuilder view: () -> some View) -> some View {
        blur(radius: isPresented ? Constants.blurRadius : 0)
            .overlay {
                ZStack {
                    if isPresented {
                        ColorPalette.background
                            .opacity(Constants.scrimOpacity)
                            .ignoresSafeArea()
                            .transition(.opacity)

                        view()
                            .maxSize()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: Constants.duration), value: isPresented)
            }
    }

}

private enum Constants {

    static let scrimOpacity: CGFloat = 0.8
    static let blurRadius: CGFloat = 8
    static let duration: TimeInterval = 0.25

}
