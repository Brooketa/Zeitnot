public struct TimeControl: Hashable, Codable, Sendable {

    public let baseMinutes: Int
    public let incrementSeconds: Int

    public init(baseMinutes: Int, incrementSeconds: Int) {
        self.baseMinutes = baseMinutes
        self.incrementSeconds = incrementSeconds
    }

}

public extension TimeControl {

    var baseTime: Duration {
        .seconds(baseMinutes * Constants.secondsPerMinute)
    }

    var increment: Duration {
        .seconds(incrementSeconds)
    }

}

private extension TimeControl {

    enum Constants {

        static let secondsPerMinute = 60

    }

}
