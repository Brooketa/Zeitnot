import UIKit

public final class OrientationService: OrientationServiceProtocol {

    public static let shared: OrientationServiceProtocol = OrientationService()

    public var supportedOrientations: UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return .all }

        return isLandscapeEnabled ? .landscape : .portrait
    }

    private var isLandscapeEnabled = false

    private var activeWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { scene in scene as? UIWindowScene }
            .first { scene in scene.activationState == .foregroundActive }
    }

    private init() {}

    public func enableLandscape() {
        isLandscapeEnabled = true
        refreshSupportedOrientations()
    }

    public func disableLandscape() {
        isLandscapeEnabled = false
        refreshSupportedOrientations()
    }

}

private extension OrientationService {

    func refreshSupportedOrientations() {
        guard let activeWindowScene else { return }

        activeWindowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        activeWindowScene.requestGeometryUpdate(.iOS(interfaceOrientations: supportedOrientations))
    }

}
