import SwiftUI

private struct LandscapeSupportModifier: ViewModifier {

    private let orientationService: OrientationServiceProtocol = OrientationService.shared

    func body(content: Content) -> some View {
        content
            .onAppear {
                orientationService.enableLandscape()
            }
            .onDisappear {
                orientationService.disableLandscape()
            }
    }

}

public extension View {

    func supportsLandscape() -> some View {
        modifier(LandscapeSupportModifier())
    }

}
