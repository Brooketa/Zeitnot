struct DialHands: Equatable {

    let minuteDegrees: Double
    let secondDegrees: Double

    init(remaining: Duration) {
        let remaining = max(remaining, .zero)

        minuteDegrees = Self.degrees(of: remaining, period: Constants.minuteHandPeriod)
        secondDegrees = Self.degrees(of: remaining, period: Constants.secondHandPeriod)
    }

}

private extension DialHands {

    enum Constants {

        static let minuteHandPeriod = Duration.seconds(3600)
        static let secondHandPeriod = Duration.seconds(60)
        static let degreesPerRevolution: Double = 360

    }

    static func degrees(of remaining: Duration, period: Duration) -> Double {
        remaining / period * Constants.degreesPerRevolution
    }

}
