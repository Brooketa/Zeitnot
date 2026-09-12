import Testing
@testable import Shared

struct TickerTests {

    @Test
    func tickingRepeatsUntilStopped() async throws {
        let ticker = Ticker()
        let counter = TickCounter()

        ticker.start(interval: .milliseconds(10)) {
            counter.count += 1
        }

        try await waitUntil { counter.count > 1 }
        ticker.stop()

        let countAtStop = counter.count

        #expect(countAtStop > 1)

        try await Task.sleep(for: .milliseconds(100))

        #expect(counter.count == countAtStop)
    }

    @Test
    func startingAgainReplacesTheRunningTick() async throws {
        let ticker = Ticker()
        let first = TickCounter()
        let second = TickCounter()

        ticker.start(interval: .milliseconds(10)) {
            first.count += 1
        }

        ticker.start(interval: .milliseconds(10)) {
            second.count += 1
        }

        try await waitUntil { second.count > 1 }
        ticker.stop()

        #expect(first.count == 0)
        #expect(second.count > 1)
    }

    @Test
    func tickingStopsWhenTickerIsReleased() async throws {
        var ticker: Ticker? = Ticker()
        let counter = TickCounter()

        ticker?.start(interval: .milliseconds(10)) {
            counter.count += 1
        }

        try await waitUntil { counter.count > 1 }
        ticker = nil

        let countAtRelease = counter.count

        #expect(countAtRelease > 1)

        try await Task.sleep(for: .milliseconds(100))

        #expect(counter.count == countAtRelease)
    }

}

private extension TickerTests {

    func waitUntil(_ condition: () -> Bool) async throws {
        let deadline = ContinuousClock.now.advanced(by: Constants.timeout)

        while ContinuousClock.now < deadline {
            guard !condition() else { return }

            try await Task.sleep(for: Constants.pollInterval)
        }
    }

}

private enum Constants {

    static let timeout = Duration.seconds(5)
    static let pollInterval = Duration.milliseconds(5)

}

private final class TickCounter {

    var count = 0

}
