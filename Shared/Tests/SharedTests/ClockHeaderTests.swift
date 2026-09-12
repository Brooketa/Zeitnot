import Foundation
import Testing
@testable import Shared

struct ClockHeaderTests: ClockPresenterTestSuite {

    let timeSource = FakeTimeSource()
    let router = FakeClockRouter()

    @Test
    func theHeaderCarriesTheRulesetItWasConstructedWith() {
        let presenter = makePresenter(category: .classical, baseMinutes: 90, incrementSeconds: 30)

        #expect(presenter.headerModel.category == RulesetCategory.classical)
        #expect(presenter.headerModel.baseMinutes == 90)
        #expect(presenter.headerModel.incrementSeconds == 30)
    }

    @Test
    func theHeaderKeepsAZeroIncrement() {
        let presenter = makePresenter(category: .bullet, baseMinutes: 1, incrementSeconds: 0)

        #expect(presenter.headerModel.category == RulesetCategory.bullet)
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
}
