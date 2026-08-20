import Testing
import Core
@testable import Clock

struct GameServiceTests {

    private let timeSource = FakeTimeSource()

    @Test
    func aNewGameHasNotStartedWithFullClocks() {
        let service = makeService(baseMinutes: 5)
        let state = service.state

        #expect(state.phase == .notStarted)
        #expect(state.white == PlayerClock(remaining: .seconds(300), moveCount: 0))
        #expect(state.black == PlayerClock(remaining: .seconds(300), moveCount: 0))
    }

    @Test
    func startingRunsWhitesClockOnly() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(10))
        let state = service.state

        #expect(state.phase == .running(player: .white))
        #expect(state.white.remaining == .seconds(290))
        #expect(state.black.remaining == .seconds(300))
    }

    @Test
    func endingATurnCreditsTheIncrementToThePlayerWhoMoved() {
        let service = makeService(baseMinutes: 5, incrementSeconds: 3)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.endTurn()
        let state = service.state

        #expect(state.white.remaining == .seconds(293))
        #expect(state.black.remaining == .seconds(300))
        #expect(state.phase == .running(player: .black))
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
        let state = service.state

        #expect(state.white.moveCount == 2)
        #expect(state.black.moveCount == 1)
    }

    @Test
    func noTimeIsConsumedWhilePaused() {
        let service = makeService(baseMinutes: 5)

        service.start()
        timeSource.advance(by: .seconds(10))
        service.pause()
        timeSource.advance(by: .seconds(3600))
        let state = service.state

        #expect(state.phase == .paused(player: .white))
        #expect(state.white.remaining == .seconds(290))
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
        let state = service.state

        #expect(state.phase == .running(player: .white))
        #expect(state.white.remaining == .seconds(285))
        #expect(state.white.moveCount == 0)
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
        let state = service.state

        #expect(state.phase == .notStarted)
        #expect(state.white == PlayerClock(remaining: .seconds(300), moveCount: 0))
        #expect(state.black == PlayerClock(remaining: .seconds(300), moveCount: 0))
    }

    @Test
    func runningOutOfTimeFinishesTheGameExactlyAtZero() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .seconds(60))
        let state = service.state

        #expect(state.phase == .finished(winner: .black))
        #expect(state.white.remaining == .zero)
    }

    @Test
    func aClockIsStillRunningOneTickBeforeZero() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .milliseconds(59_999))
        let state = service.state

        #expect(state.phase == .running(player: .white))
        #expect(state.white.remaining == .milliseconds(1))
    }

    @Test
    func aClockNeverGoesNegative() {
        let service = makeService(baseMinutes: 1)

        service.start()
        timeSource.advance(by: .seconds(600))

        #expect(service.state.white.remaining == .zero)
    }

    @Test
    func aPlayerWhoRunsOutOfTimeIsCreditedNoIncrement() {
        let service = makeService(baseMinutes: 1, incrementSeconds: 30)

        service.start()
        timeSource.advance(by: .seconds(60))
        service.endTurn()
        let state = service.state

        #expect(state.phase == .finished(winner: .black))
        #expect(state.white.remaining == .zero)
        #expect(state.white.moveCount == 0)
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

        #expect(service.state.phase == .finished(winner: .black))

        service.reset()

        #expect(service.state.phase == .notStarted)
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
        let state = service.state

        #expect(state.white.remaining == baseTime - timeSpent + incrementEarned)
        #expect(state.black.remaining == baseTime - timeSpent + incrementEarned)
        #expect(state.white.moveCount == 50)
        #expect(state.black.moveCount == 50)
    }

    private func makeService(baseMinutes: Int, incrementSeconds: Int = 0) -> GameService {
        GameService(
            timeControl: TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds),
            timeSource: timeSource)
    }

}
