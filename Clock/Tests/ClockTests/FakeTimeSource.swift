@testable import Clock

final class FakeTimeSource: TimeSourceProtocol {

    private(set) var now: ContinuousClock.Instant

    init(now: ContinuousClock.Instant = ContinuousClock.now) {
        self.now = now
    }

    func advance(by duration: Duration) {
        now = now.advanced(by: duration)
    }

}
