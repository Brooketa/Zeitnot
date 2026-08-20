import Testing
import Core
@testable import Clock

struct ClockResettingTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func resettingAGameThatHasNotStartedNeedsNoConfirmation() {
        let presenter = makePresenter()

        presenter.reset()

        #expect(!presenter.showResetDialog)
        #expect(presenter.whiteClock.state == .awaitingStart)
    }

    @Test
    func resettingAGameInProgressAsksFirstAndChangesNothingYet() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.reset()

        #expect(presenter.showResetDialog)
        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.time == "2:50")
    }

    @Test
    func resettingWhilePausedAsksFirst() {
        let presenter = makePresenter()

        presenter.press(.black)
        presenter.pause()
        presenter.reset()

        #expect(presenter.showResetDialog)
    }

    @Test
    func confirmingTheResetRestoresAFreshGame() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.white)
        presenter.reset()
        presenter.confirmReset()

        #expect(!presenter.showResetDialog)
        #expect(presenter.whiteClock.time == "3:00")
        #expect(presenter.blackClock.time == "3:00")
        #expect(presenter.whiteClock.state == .awaitingStart)
        #expect(presenter.blackClock.caption == "Press to start")
        #expect(presenter.headerModel.moveNumber == 1)
    }

    @Test
    func cancellingTheResetKeepsTheGameRunning() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.reset()
        presenter.cancelReset()
        timeSource.advance(by: .seconds(5))

        #expect(!presenter.showResetDialog)
        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.time == "2:45")
    }

    @Test
    func resettingAFinishedGameNeedsNoConfirmation() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.reset()

        #expect(!presenter.showResetDialog)
        #expect(presenter.whiteClock.time == "1:00")
        #expect(presenter.whiteClock.state == .awaitingStart)
    }

    @Test
    func resettingClearsTheFlaggedClock() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.press(.white)
        presenter.reset()

        #expect(presenter.whiteClock.state == .awaitingStart)
        #expect(presenter.whiteClock.caption == nil)
        #expect(presenter.controlBarModel.canPause)
    }
}
