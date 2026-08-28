public protocol TickerProtocol {

    func start(interval: Duration, onTick: @escaping () -> Void)
    func stop()

}
