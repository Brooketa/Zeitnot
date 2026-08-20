import Testing
import Observation
import Core
@testable import Clock

struct ClockPresenterObservationTests {

    private let timeSource = FakeTimeSource()

    @Test
    func pressingInvalidatesEveryObserverOfTheClockModels() {
        let presenter = makePresenter()
        let observation = ObservationFlag()

        withObservationTracking {
            _ = presenter.whiteClock
            _ = presenter.isPaused
        } onChange: {
            observation.fired = true
        }

        presenter.press(.black)

        #expect(observation.fired)
    }

    @Test
    func resettingInvalidatesEveryObserverOfTheClockModels() {
        let presenter = makePresenter()
        let observation = ObservationFlag()

        presenter.press(.black)

        withObservationTracking {
            _ = presenter.whiteClock
        } onChange: {
            observation.fired = true
        }

        presenter.reset()
        presenter.confirmReset()

        #expect(observation.fired)
    }

    private func makePresenter() -> ClockPresenter {
        let timeControl = TimeControl(baseMinutes: 3, incrementSeconds: 2)

        return ClockPresenter(
            gameConfiguration: GameConfiguration(timeControl: timeControl, category: "Blitz"),
            gameService: GameService(timeControl: timeControl, timeSource: timeSource))
    }

}

private nonisolated final class ObservationFlag: @unchecked Sendable {

    var fired = false

}
