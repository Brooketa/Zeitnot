public struct TimeControl: Hashable, Codable, Sendable {

    public let baseMinutes: Int
    public let incrementSeconds: Int

    public init(baseMinutes: Int, incrementSeconds: Int) {
        self.baseMinutes = baseMinutes
        self.incrementSeconds = incrementSeconds
    }

}

public extension TimeControl {

    static let bullet1plus0 = TimeControl(baseMinutes: 1, incrementSeconds: 0)
    static let blitz3plus2 = TimeControl(baseMinutes: 3, incrementSeconds: 2)
    static let blitz5plus0 = TimeControl(baseMinutes: 5, incrementSeconds: 0)
    static let rapid10plus0 = TimeControl(baseMinutes: 10, incrementSeconds: 0)
    static let rapid15plus10 = TimeControl(baseMinutes: 15, incrementSeconds: 10)
    static let classical90plus30 = TimeControl(baseMinutes: 90, incrementSeconds: 30)

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
