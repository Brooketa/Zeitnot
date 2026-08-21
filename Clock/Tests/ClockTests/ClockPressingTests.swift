import Testing
import Core
@testable import Clock

struct ClockPressingTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()



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
    }

    @Test
    func pressingTheHalfOfThePlayerToMoveSwitchesTurns() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.white)

        #expect(presenter.blackClock.state == .toMove)
        #expect(presenter.whiteClock.state == .waiting)
        #expect(presenter.whiteClock.reading == "2:52")
    }

    @Test
    func pressingTheOpponentsHalfIsIgnored() {
        let presenter = makePresenter()

        presenter.press(.black)
        timeSource.advance(by: .seconds(10))
        presenter.press(.black)

        #expect(presenter.whiteClock.state == .toMove)
        #expect(presenter.whiteClock.reading == "2:50")
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

        #expect(presenter.whiteClock.reading == "0:00")
        #expect(presenter.whiteClock.state == .flagged)
        #expect(presenter.blackClock.state == .waiting)
    }
}
