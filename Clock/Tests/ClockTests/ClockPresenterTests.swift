import Testing
import Core
@testable import Clock

struct ClockPresenterTests {

    private let timeSource = FakeTimeSource()

    @Test
    func titleNamesTheRulesetItWasConstructedWith() {
        let presenter = makePresenter(category: "Classical", baseMinutes: 90, incrementSeconds: 30)

        #expect(presenter.title == "● CLASSICAL · 90 | 30")
    }

    @Test
    func titleUppercasesTheCategory() {
        let presenter = makePresenter(category: "Blitz", baseMinutes: 3, incrementSeconds: 2)

        #expect(presenter.title == "● BLITZ · 3 | 2")
    }

    @Test
    func titleKeepsAZeroIncrement() {
        let presenter = makePresenter(category: "Bullet", baseMinutes: 1, incrementSeconds: 0)

        #expect(presenter.title == "● BULLET · 1 | 0")
    }

    @Test
    func theMoveNumberStartsAtMoveOne() {
        let presenter = makePresenter()

        #expect(String(localized: presenter.moveNumber) == "Move 1")
    }

    @Test
    func theMoveNumberAdvancesOnceBlackHasReplied() {
        let presenter = makePresenter()

        presenter.press(.black)
        presenter.press(.white)
        presenter.press(.black)

        #expect(String(localized: presenter.moveNumber) == "Move 2")
    }

    @Test
    func blacksCardPromptsToPressBeforeTheGameStarts() {
        let presenter = makePresenter()

        #expect(presenter.blackClock.caption == "Press to start")
        #expect(presenter.whiteClock.caption == nil)
    }

    @Test
    func thePromptDisappearsOnceTheGameHasStarted() {
        let presenter = makePresenter()

        presenter.press(.black)

        #expect(presenter.blackClock.caption == nil)
    }

    @Test
    func pressingBlacksHalfStartsWhitesClock() {
        let presenter = makePresenter()

        presenter.press(.black)

        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.blackClock.state == .waiting)
    }

    @Test
    func pressingWhitesHalfBeforeTheGameStartsIsIgnored() {
        let presenter = makePresenter()

        presenter.press(.white)

        #expect(presenter.whiteClock.state == .awaitingStart)
        #expect(presenter.blackClock.state == .awaitingStart)
        #expect(presenter.blackClock.caption == "Press to start")
    }

    @Test
    func pressingTheHalfOfThePlayerToMoveSwitchesTurns() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.white)

        #expect(presenter.blackClock.state == .toMove)
        #expect(presenter.whiteClock.state == .waiting)
        #expect(presenter.whiteClock.time == "2:52")
        #expect(presenter.whiteClock.caption == nil)
    }

    @Test
    func pressingTheOpponentsHalfIsIgnored() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.time == "2:50")
    }

    @Test
    func aDoublePressOnTheSameHalfSwitchesOnce() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.white)
        presenter.press(.white)

        #expect(presenter.blackClock.state == .toMove)
        #expect(String(localized: presenter.moveNumber) == "Move 1")
    }

    @Test
    func pressingIsIgnoredOnceAClockHasRunOut() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(presenter.whiteClock.time == "0:00")
        #expect(presenter.whiteClock.state == .waiting)
        #expect(presenter.blackClock.state == .waiting)
    }

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
        #expect(String(localized: presenter.moveNumber) == "Move 1")
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

    private func makePresenter(
        category: String = "Blitz",
        baseMinutes: Int = 3,
        incrementSeconds: Int = 2
    ) -> ClockPresenter {
        let timeControl = TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds)

        return ClockPresenter(
            gameConfiguration: GameConfiguration(timeControl: timeControl, category: category),
            gameService: GameService(timeControl: timeControl, timeSource: timeSource))
    }

}
