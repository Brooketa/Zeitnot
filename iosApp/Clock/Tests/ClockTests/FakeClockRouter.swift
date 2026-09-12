@testable import Clock
import Shared

final class FakeClockRouter: ClockRoutingProtocol {

    private(set) var didNavigateBack = false

    func navigateBack() {
        didNavigateBack = true
    }

}
