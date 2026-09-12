@testable import Shared

final class FakeTimeSource: TimeSourceProtocol, TickerProtocol {

    private(set) var now: ContinuousClock.Instant

    private var interval: Duration?
    private var lastTick: ContinuousClock.Instant?
    private var onTick: (() -> Void)?

    init(now: ContinuousClock.Instant = ContinuousClock.now) {
        self.now = now
    }

    func start(interval: Duration, onTick: @escaping () -> Void) {
        self.interval = interval
        self.onTick = onTick
        lastTick = now
    }

    func stop() {
        interval = nil
        lastTick = nil
        onTick = nil
    }

    func advance(by duration: Duration) {
        let target = now.advanced(by: duration)

        while let deadline = nextDeadline, deadline <= target {
            now = deadline
            lastTick = deadline
            onTick?()
        }

        now = target
    }

    func advanceWithoutTicking(by duration: Duration) {
        now = now.advanced(by: duration)
        lastTick = now
    }

}

private extension FakeTimeSource {

    var nextDeadline: ContinuousClock.Instant? {
        guard
            let interval,
            let lastTick,
            onTick != nil,
            interval > .zero
        else { return nil }

        return lastTick.advanced(by: interval)
    }

}
