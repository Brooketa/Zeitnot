import Testing
import Core
@testable import Clock

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
        #expect(presenter.whiteClock.caption == "Flag fell")
        #expect(presenter.blackClock.state == .waiting)
        #expect(presenter.blackClock.caption == nil)
    }

    @Test
    func pausingIsUnavailableOnceAClockHasRunOut() {
        let presenter = makePresenter(baseMinutes: 1)

        #expect(presenter.controlBarModel.canPause)

        presenter.press(.black)

        #expect(presenter.controlBarModel.canPause)

        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(!presenter.controlBarModel.canPause)
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
