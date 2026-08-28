@testable import Clock

final class FakeClockRouter: ClockRoutingProtocol {

    private(set) var didNavigateBack = false

    func navigateBack() {
        didNavigateBack = true
    }

}
