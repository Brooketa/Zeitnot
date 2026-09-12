@testable import Shared

protocol ClockPresenterTestSuite {

    var timeSource: FakeTimeSource { get }
    var router: FakeClockRouter { get }

}

extension ClockPresenterTestSuite {

    func makePresenter(
        category: RulesetCategory = .blitz,
        baseMinutes: Int = 3,
        incrementSeconds: Int = 2
    ) -> ClockPresenter {
        let timeControl = TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds)

        return ClockPresenter(
            gameConfiguration: GameConfiguration(timeControl: timeControl, category: category),
            gameService: GameService(timeControl: timeControl, timeSource: timeSource, ticker: timeSource),
            router: router)
    }

}

extension ClockFaceModel {

    var reading: String {
        switch timeDisplay {
        case let .digital(digital): digital.reading
        case let .analog(analog): analog.hands.remaining.timeReading
        }
    }

}

extension ClockPresenter {

    var whiteClock: ClockFaceModel {
        clocksModel.white
    }

    var blackClock: ClockFaceModel {
        clocksModel.black
    }

}

private extension DialHands {

    static let secondsPerMinuteHandDegree: Double = 10

    var remaining: Duration {
        .seconds(minuteDegrees * Self.secondsPerMinuteHandDegree)
    }

}

extension ClockFaceTimeDisplay {

    var isAnalog: Bool {
        if case .analog = self { true } else { false }
    }

}
