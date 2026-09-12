import Testing
@testable import Shared

struct ClockFlaggingTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func theClockThatRanOutIsFlaggedAndSaysSo() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(presenter.whiteClock.state == .flagged)
        #expect(presenter.blackClock.state == .waiting)
    }

    @Test
    func pausingIsUnavailableOnceAClockHasRunOut() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)

        #expect(presenter.controlBarModel.canPause)

        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(!presenter.controlBarModel.canPause)
    }

    @Test
    func pressingAfterAFlagFallsDoesNotHandTheTurnToTheOpponent() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advanceWithoutTicking(by: .seconds(60))
        presenter.press(.white)

        #expect(presenter.whiteClock.state == .flagged)
        #expect(presenter.blackClock.state == .waiting)
        #expect(presenter.blackClock.reading == "1:00")
        #expect(!presenter.isCountingDown)
    }

    @Test
    func aFlaggedClockIsNotWarning() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(presenter.whiteClock.state == .flagged)
    }
}
