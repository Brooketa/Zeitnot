import Testing
import Core
@testable import Clock

struct ClockPresenterTests {

    private let timeSource = FakeTimeSource()
    private let router = FakeClockRouter()

    @Test
    func theHeaderCarriesTheRulesetItWasConstructedWith() {
        let presenter = makePresenter(category: "Classical", baseMinutes: 90, incrementSeconds: 30)

        #expect(presenter.headerModel.category == "Classical")
        #expect(presenter.headerModel.baseMinutes == 90)
        #expect(presenter.headerModel.incrementSeconds == 30)
    }

    @Test
    func theHeaderCarriesTheCategoryInNaturalCasing() {
        let presenter = makePresenter(category: "Blitz", baseMinutes: 3, incrementSeconds: 2)

        #expect(presenter.headerModel.category == "Blitz")
    }

    @Test
    func theHeaderKeepsAZeroIncrement() {
        let presenter = makePresenter(category: "Bullet", baseMinutes: 1, incrementSeconds: 0)

        #expect(presenter.headerModel.category == "Bullet")
        #expect(presenter.headerModel.incrementSeconds == 0)
    }

    @Test
    func theMoveNumberStartsAtMoveOne() {
        let presenter = makePresenter()

        #expect(presenter.headerModel.moveNumber == 1)
    }

    @Test
    func theMoveNumberAdvancesOnceBlackHasReplied() {
        let presenter = makePresenter()

        presenter.press(.black)
        presenter.press(.white)
        presenter.press(.black)

        #expect(presenter.headerModel.moveNumber == 2)
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
        #expect(presenter.headerModel.moveNumber == 1)
    }

    @Test
    func pressingIsIgnoredOnceAClockHasRunOut() {
        let presenter = makePresenter(baseMinutes: 1)

        presenter.press(.black)
        timeSource.advance(by: .seconds(60))
        presenter.press(.white)

        #expect(presenter.whiteClock.time == "0:00")
        #expect(presenter.whiteClock.state == .flagged)
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
    func theHeaderDotIsLitOnlyWhileTheClockCountsDown() {
        let presenter = makePresenter(baseMinutes: 1)

        #expect(!presenter.headerModel.isRunning)

        presenter.press(.black)

        #expect(presenter.headerModel.isRunning)

        presenter.pause()

        #expect(!presenter.headerModel.isRunning)

        presenter.resume()
        timeSource.advance(by: .seconds(60))

        #expect(!presenter.headerModel.isRunning)
    }

    @Test
    func theBackControlRoutesBack() {
        let presenter = makePresenter()

        presenter.navigateBack()

        #expect(router.didNavigateBack)
    }

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

    private func makePresenter(
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
