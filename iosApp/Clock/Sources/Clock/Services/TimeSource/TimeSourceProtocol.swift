public protocol TimeSourceProtocol {

    var now: ContinuousClock.Instant { get }

}
