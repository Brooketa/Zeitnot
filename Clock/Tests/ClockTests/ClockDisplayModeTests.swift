import Testing
import Core
@testable import Clock

struct ClockDisplayModeTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func theClockStartsOnTheDigitalFace() {
        let presenter = makePresenter()

        #expect(presenter.displayMode == .digital)
        #expect(!presenter.whiteClock.timeDisplay.isAnalog)
        #expect(!presenter.blackClock.timeDisplay.isAnalog)
    }

    @Test
    func selectingAModeChangesBothClocksTogether() {
        let presenter = makePresenter()

        presenter.selectDisplayMode(.analog)

        #expect(presenter.whiteClock.timeDisplay.isAnalog)
        #expect(presenter.blackClock.timeDisplay.isAnalog)

        presenter.selectDisplayMode(.digital)

        #expect(!presenter.whiteClock.timeDisplay.isAnalog)
        #expect(!presenter.blackClock.timeDisplay.isAnalog)
    }

    @Test
    func theControlBarReportsTheSelectedMode() {
        let presenter = makePresenter()

        #expect(presenter.controlBarModel.displayModeControl.displayMode == .digital)

        presenter.selectDisplayMode(.analog)

        #expect(presenter.controlBarModel.displayModeControl.displayMode == .analog)
    }

    @Test
    func switchingWhileRunningDisturbsNothing() {
        let presenter = makePresenter(baseMinutes: 3)

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))

        let moveNumber = presenter.headerModel.moveNumber

        presenter.selectDisplayMode(.analog)

        #expect(presenter.isCountingDown)
        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.blackClock.state == .waiting)
        #expect(presenter.whiteClock.reading == "2:50")
        #expect(presenter.headerModel.moveNumber == moveNumber)

        timeSource.advance(by: .seconds(5))

        #expect(presenter.whiteClock.reading == "2:45")
    }

    @Test
    func switchingWorksWhilePaused() {
        let presenter = makePresenter(baseMinutes: 3)

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.pause()

        presenter.selectDisplayMode(.analog)

        #expect(presenter.showPauseDialog)
        #expect(presenter.whiteClock.timeDisplay.isAnalog)
        #expect(presenter.whiteClock.reading == "2:50")

        timeSource.advance(by: .seconds(30))

        #expect(presenter.whiteClock.reading == "2:50")
    }

    @Test
    func switchingWorksAfterGameOver() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))

        #expect(presenter.whiteClock.state == .flagged)

        presenter.selectDisplayMode(.analog)

        #expect(presenter.whiteClock.state == .flagged)
        #expect(presenter.whiteClock.timeDisplay.isAnalog)
        #expect(presenter.whiteClock.reading == "0:00")
    }

    @Test
    func switchingRepeatedlyDuringAGameLeavesItCorrect() {
        let presenter = makePresenter(baseMinutes: 3)

        presenter.press(.black)

        for _ in 0..<5 {
            timeSource.advance(by: .seconds(2))
            presenter.selectDisplayMode(.analog)
            presenter.selectDisplayMode(.digital)
        }

        presenter.press(.white)

        #expect(presenter.whiteClock.reading == "2:52")
        #expect(presenter.blackClock.state == .toMove)
        #expect(presenter.headerModel.moveNumber == 1)
    }

}
