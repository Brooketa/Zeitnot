import Testing
@testable import Shared

struct GameServiceTests {

    private let timeSource = FakeTimeSource()

    @Test
    func aNewGameHasNotStartedWithFullClocks() {
        let service = makeService(baseMinutes: 5)
        let snapshot = service.snapshot

        #expect(snapshot.isAwaitingStart)
        #expect(snapshot.white.remaining == .seconds(300))
        #expect(snapshot.white.moveCount == 0)
        #expect(snapshot.black.remaining == .seconds(300))
        #expect(snapshot.black.moveCount == 0)
    }

    @Test
    func startingRunsWhitesClockOnly() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(10))
        let snapshot = service.snapshot

        #expect(snapshot.isRunning)
        #expect(snapshot.playerToMove == .white)
        #expect(snapshot.white.remaining == .seconds(290))
        #expect(snapshot.black.remaining == .seconds(300))
    }

    @Test
    func endingATurnCreditsTheIncrementToThePlayerWhoMoved() {
        let service = makeService(baseMinutes: 5, incrementSeconds: 3)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.endTurn()
        let snapshot = service.snapshot

        #expect(snapshot.white.remaining == .seconds(293))
        #expect(snapshot.black.remaining == .seconds(300))
        #expect(snapshot.isRunning)
        #expect(snapshot.playerToMove == .black)
    }

    @Test
    func movesAreCountedPerPlayerAndOnlyOnCompletedTurns() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(1))
        service.endTurn()
        timeSource.advance(by: .seconds(1))
        service.endTurn()
        timeSource.advance(by: .seconds(1))
        service.endTurn()
        timeSource.advance(by: .seconds(1))
        let snapshot = service.snapshot

        #expect(snapshot.white.moveCount == 2)
        #expect(snapshot.black.moveCount == 1)
    }

    @Test
    func noTimeIsConsumedWhilePaused() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.pause()
        timeSource.advance(by: .seconds(3600))
        let snapshot = service.snapshot

        #expect(snapshot.isPaused)
        #expect(snapshot.playerToMove == .white)
        #expect(snapshot.white.remaining == .seconds(290))
    }

    @Test
    func resumingContinuesTheSameTurn() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.pause()
        timeSource.advance(by: .seconds(3600))
        service.resume()
        timeSource.advance(by: .seconds(5))
        let snapshot = service.snapshot

        #expect(snapshot.isRunning)
        #expect(snapshot.playerToMove == .white)
        #expect(snapshot.white.remaining == .seconds(285))
        #expect(snapshot.white.moveCount == 0)
    }

    @Test
    func resettingRestoresFullClocksAndZeroMoveCounts() {
        let service = makeService(baseMinutes: 5, incrementSeconds: 3)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.endTurn()
        timeSource.advance(by: .seconds(10))
        service.reset()
        timeSource.advance(by: .seconds(10))
        let snapshot = service.snapshot

        #expect(snapshot.isAwaitingStart)
        #expect(snapshot.white.remaining == .seconds(300))
        #expect(snapshot.white.moveCount == 0)
        #expect(snapshot.black.remaining == .seconds(300))
        #expect(snapshot.black.moveCount == 0)
    }

    @Test
    func runningOutOfTimeFinishesTheGameExactlyAtZero() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .seconds(60))
        let snapshot = service.snapshot

        #expect(snapshot.isFinished)
        #expect(snapshot.winner == .black)
        #expect(snapshot.white.remaining == .zero)
    }

    @Test
    func aClockIsStillRunningOneTickBeforeZero() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .milliseconds(59_900))
        let snapshot = service.snapshot

        #expect(snapshot.isRunning)
        #expect(snapshot.playerToMove == .white)
        #expect(snapshot.white.remaining == .milliseconds(100))
    }

    @Test
    func aClockWithLessThanATickLeftCanStillEndItsTurn() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advanceWithoutTicking(by: .milliseconds(59_999))
        service.endTurn()

        #expect(service.snapshot.isRunning)
        #expect(service.snapshot.playerToMove == .black)
        #expect(service.snapshot.white.remaining == .milliseconds(1))
    }

    @Test
    func aClockNeverGoesNegative() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .seconds(600))

        #expect(service.snapshot.white.remaining == .zero)
    }

    @Test
    func aPlayerWhoRunsOutOfTimeIsCreditedNoIncrement() {
        let service = makeService(baseMinutes: 1, incrementSeconds: 30)

        service.start()
        timeSource.advance(by: .seconds(60))
        service.endTurn()
        let snapshot = service.snapshot

        #expect(snapshot.isFinished)
        #expect(snapshot.winner == .black)
        #expect(snapshot.white.remaining == .zero)
        #expect(snapshot.white.moveCount == 0)
    }

    @Test
    func aClockThatRanOutCannotEndItsTurnBeforeTheNextTick() {
        let service = makeService(baseMinutes: 1, incrementSeconds: 30)

        service.start()
        timeSource.advanceWithoutTicking(by: .seconds(60))
        service.endTurn()

        #expect(service.snapshot.isFinished)
        #expect(service.snapshot.winner == .black)
        #expect(service.snapshot.white.remaining == .zero)
        #expect(service.snapshot.white.moveCount == 0)
        #expect(service.snapshot.black.remaining == .seconds(60))
    }

    @Test
    func aClockThatRanOutCannotBePausedBeforeTheNextTick() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advanceWithoutTicking(by: .seconds(60))
        service.pause()

        #expect(service.snapshot.isFinished)
        #expect(service.snapshot.winner == .black)
    }

    @Test
    func aFinishedGameIgnoresEveryTransitionExceptReset() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .seconds(60))
        service.endTurn()
        service.start()
        service.resume()
        service.pause()

        #expect(service.snapshot.isFinished)
        #expect(service.snapshot.winner == .black)

        service.reset()

        #expect(service.snapshot.isAwaitingStart)
    }

    @Test
    func aLongGameDoesNotAccumulateDrift() {
        let service = makeService(baseMinutes: 90, incrementSeconds: 30)

        service.start()

        for _ in 0..<100 {
            timeSource.advance(by: .milliseconds(1_500))
            service.endTurn()
        }

        let baseTime = Duration.seconds(5_400)
        let timeSpent = Duration.milliseconds(1_500 * 50)
        let incrementEarned = Duration.seconds(30 * 50)
        let snapshot = service.snapshot

        #expect(snapshot.white.remaining == baseTime - timeSpent + incrementEarned)
        #expect(snapshot.black.remaining == baseTime - timeSpent + incrementEarned)
        #expect(snapshot.white.moveCount == 50)
        #expect(snapshot.black.moveCount == 50)
    }

    private func makeService(baseMinutes: Int, incrementSeconds: Int = 0) -> GameService {
        GameService(
            timeControl: TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds),
            timeSource: timeSource,
            ticker: timeSource)
    }

}
