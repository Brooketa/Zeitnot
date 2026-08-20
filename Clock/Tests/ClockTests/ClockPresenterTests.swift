import Testing
import Core
@testable import Clock

struct ClockPresenterTests {

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
        let presenter = makePresenter(category: "Blitz", baseMinutes: 3, incrementSeconds: 2)

        #expect(String(localized: presenter.moveNumber) == "Move 1")
    }

    private func makePresenter(category: String, baseMinutes: Int, incrementSeconds: Int) -> ClockPresenter {
        let timeControl = TimeControl(baseMinutes: baseMinutes, incrementSeconds: incrementSeconds)

        return ClockPresenter(
            gameConfiguration: GameConfiguration(timeControl: timeControl, category: category),
            gameService: GameService(timeControl: timeControl, timeSource: FakeTimeSource()))
    }

}
