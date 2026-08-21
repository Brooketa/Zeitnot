import Testing
import Core
@testable import Clock

struct ClockLowTimeWarningTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func theRunningClockWarnsBelowTenSeconds() {
        let presenter = makePresenter(baseMinutes: 3)

        presenter.press(.black)
        timeSource.advance(by: .seconds(169))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.reading == "0:11")

        timeSource.advance(by: .seconds(2))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .lowTime)
        #expect(presenter.blackClock.state == .waiting)
    }

    @Test
    func theWarningClearsOnSwitchingPausingAndResetting() {
        let presenter = makePresenter(baseMinutes: 3)

        presenter.press(.black)
        timeSource.advance(by: .seconds(175))
        presenter.press(.white)

        #expect(presenter.whiteClock.state == .waiting)
        #expect(presenter.blackClock.state == .toMove)

        presenter.press(.black)

        #expect(presenter.whiteClock.state == .lowTime)

        presenter.pause()

        #expect(presenter.whiteClock.state == .toMove)

        presenter.resume()
        presenter.reset()
        presenter.confirmReset()

        #expect(presenter.whiteClock.state == .awaitingStart)
    }

    @Test
    func aBulletGameWarnsLaterThanTenSecondsWouldAllow() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(52))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.reading == "0:08")

        timeSource.advance(by: .seconds(3))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .lowTime)
    }
}
