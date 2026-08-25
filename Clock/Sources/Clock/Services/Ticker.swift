public final class Ticker: TickerProtocol {

    private var task: Task<Void, Never>?

    public init() {}

    public func start(interval: Duration, onTick: @escaping () -> Void) {
        stop()

        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)

                guard !Task.isCancelled else { return }

                onTick()
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
    }

}
