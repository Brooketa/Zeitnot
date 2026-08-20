import UIKit

public protocol OrientationServiceProtocol {

    var supportedOrientations: UIInterfaceOrientationMask { get }

    func enableLandscape()
    func disableLandscape()

}
