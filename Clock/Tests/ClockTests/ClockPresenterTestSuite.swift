import Core
@testable import Clock

protocol ClockPresenterTestSuite {

    var timeSource: FakeTimeSource { get }
    var router: FakeClockRouter { get }

}

extension ClockPresenterTestSuite {

    func makePresenter(
        category: String = "Blitz",
        baseMinutes: Int = 3,
        incrementSeconds: Int = 2
    ) -> ClockPresenter {
        let timeControl = TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds)

        return ClockPresenter(
            gameConfiguration: GameConfiguration(timeControl: timeControl, category: category),
            gameService: GameService(timeControl: timeControl, timeSource: timeSource),
            router: router)
    }

}
