public extension Duration {

    var timeReading: String {
        let totalSeconds = max(components.seconds, 0)

        let hours = totalSeconds / Constants.secondsPerHour
        let minutes = totalSeconds % Constants.secondsPerHour / Constants.secondsPerMinute
        let seconds = totalSeconds % Constants.secondsPerMinute

        guard hours > 0 else { return "\(minutes):\(padded(seconds))" }

        return "\(hours):\(padded(minutes)):\(padded(seconds))"
    }

}

private extension Duration {

    enum Constants {

        static let secondsPerMinute: Int64 = 60
        static let secondsPerHour: Int64 = 3600

    }

    func padded(_ value: Int64) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

}
