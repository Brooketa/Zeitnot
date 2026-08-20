import Testing
import Core
@testable import Clock

struct ClockPausingTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func thePauseDialogIsAbsentWhileTheGameRuns() {
        let presenter = makePresenter()

        presenter.press(.black)

        #expect(!presenter.showPauseDialog)
    }

    @Test
    func pausingNamesThePlayerToMoveOnResume() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.white)
        presenter.pause()

        #expect(presenter.showPauseDialog)
        #expect(presenter.pauseDialogModel.playerName == "Black")
    }

    @Test
    func resumingClearsThePauseDialogAndContinuesTheSameTurn() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.pause()
        timeSource.advance(by: .seconds(3600))
        presenter.resume()
        timeSource.advance(by: .seconds(5))

        #expect(!presenter.showPauseDialog)
        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.time == "2:45")
    }

    @Test
    func pressingAClockWhilePausedChangesNothing() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.pause()
        presenter.press(.white)
        presenter.press(.black)

        #expect(presenter.showPauseDialog)
        #expect(presenter.pauseDialogModel.playerName == "White")
        #expect(presenter.whiteClock.time == "2:50")
    }
}
