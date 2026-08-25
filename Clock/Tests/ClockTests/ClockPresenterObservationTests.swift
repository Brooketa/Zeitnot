import Testing
import Observation
import Core
@testable import Clock

struct ClockPresenterObservationTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func pressingInvalidatesEveryObserverOfTheClockModels() {
        let presenter = makePresenter()
        let observation = ObservationFlag()

        withObservationTracking {
            _ = presenter.whiteClock
            _ = presenter.isCountingDown
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

    @Test
    func aFlagFallInvalidatesEveryObserverOfTheClockModels() {
        let presenter = makePresenter(baseMinutes: 1)
        let observation = ObservationFlag()

        presenter.press(.black)

        withObservationTracking {
            _ = presenter.controlBarModel
        } onChange: {
            observation.fired = true
        }

        timeSource.advance(by: .seconds(120))

        #expect(observation.fired)
    }

}

private nonisolated final class ObservationFlag: @unchecked Sendable {

    var fired = false

}
