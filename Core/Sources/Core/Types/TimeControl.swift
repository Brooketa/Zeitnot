public struct TimeControl: Hashable, Codable, Sendable {

    public let baseMinutes: Int
    public let incrementSeconds: Int

    public init(baseMinutes: Int, incrementSeconds: Int) {
        self.baseMinutes = baseMinutes
        self.incrementSeconds = incrementSeconds
    }

}
