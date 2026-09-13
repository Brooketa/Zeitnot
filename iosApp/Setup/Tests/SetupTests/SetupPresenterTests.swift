import Foundation
import Testing
@testable import Setup
import Shared

struct SetupPresenterTests {

    @Test
    func bulletOnePlusZeroIsSelectedInitially() {
        let presenter = makePresenter()

        #expect(selectedIds(of: presenter) == [PresetRuleset.bullet1plus0.id])
    }

    @Test
    func exactlyOneRulesetIsSelectedAtAllTimes() {
        let presenter = makePresenter()

        for preset in PresetRuleset.allCases {
            presenter.select(preset)

            #expect(selectedIds(of: presenter) == [preset.id])
        }
    }

    @Test
    func selectingARulesetDeselectsAllOthers() {
        let presenter = makePresenter()

        presenter.select(.classical90plus30)

        #expect(selectedIds(of: presenter) == [PresetRuleset.classical90plus30.id])
    }

    @Test
    func selectingTheAlreadySelectedRulesetIsANoOp() {
        let presenter = makePresenter()

        presenter.select(.rapid15plus10)
        presenter.select(.rapid15plus10)

        #expect(selectedIds(of: presenter) == [PresetRuleset.rapid15plus10.id])
    }

    @Test
    func modelsFollowTheCatalogueOrder() {
        let presenter = makePresenter()

        #expect(presenter.rulesetModels.map(\.id) == PresetRuleset.allCases.map(\.id))
    }

    @Test
    func startGameModelCarriesTheSelectedRuleset() {
        let presenter = makePresenter()

        #expect(presenter.startGameModel.category == RulesetCategory.bullet)
        #expect(presenter.startGameModel.baseMinutes == 1)
        #expect(presenter.startGameModel.incrementSeconds == 0)
    }

    @Test
    func startGameModelFollowsTheSelection() {
        let presenter = makePresenter()

        presenter.select(.classical90plus30)

        #expect(presenter.startGameModel.category == RulesetCategory.classical)
        #expect(presenter.startGameModel.baseMinutes == 90)
        #expect(presenter.startGameModel.incrementSeconds == 30)
    }

    @Test
    func gameConfigurationCarriesTheSelectedRuleset() {
        let presenter = makePresenter()

        presenter.select(.rapid15plus10)

        #expect(presenter.gameConfiguration.timeControl == TimeControl(baseMinutes: 15, incrementSeconds: 10))
        #expect(presenter.gameConfiguration.category == .rapid)
    }

    @Test
    func gameConfigurationIsASnapshotOfTheSelectionAtTheTimeItIsRead() {
        let presenter = makePresenter()

        presenter.select(.bullet1plus0)
        let configuration = presenter.gameConfiguration
        presenter.select(.classical90plus30)

        #expect(configuration.timeControl == TimeControl(baseMinutes: 1, incrementSeconds: 0))
    }

    @Test
    func startGameNavigatesToTheClockWithTheSelectedRuleset() {
        let router = SetupRoutingSpy()
        let presenter = makePresenter(router: router)

        presenter.select(.classical90plus30)
        presenter.startGame()

        #expect(router.routedGameConfigurations.count == 1)
        #expect(router.routedGameConfigurations.first?.category == .classical)
        #expect(
            router.routedGameConfigurations.first?.timeControl
                == TimeControl(baseMinutes: 90, incrementSeconds: 30))
    }

    @Test
    func changingTheSelectionAfterStartingDoesNotAlterTheGameUnderWay() {
        let router = SetupRoutingSpy()
        let presenter = makePresenter(router: router)

        presenter.select(.bullet1plus0)
        presenter.startGame()
        presenter.select(.classical90plus30)

        #expect(
            router.routedGameConfigurations
                == [GameConfiguration(
                    timeControl: TimeControl(baseMinutes: 1, incrementSeconds: 0),
                    category: .bullet)])
    }

    @Test
    func startGameLeavesTheSelectionUntouched() {
        let presenter = makePresenter()

        presenter.select(.rapid10plus0)
        presenter.startGame()

        #expect(selectedIds(of: presenter) == [PresetRuleset.rapid10plus0.id])
    }

    private func makePresenter(router: SetupRoutingProtocol = SetupRoutingSpy()) -> SetupPresenter {
        SetupPresenter(router: router)
    }

    private func selectedIds(of presenter: SetupPresenter) -> [String] {
        presenter.rulesetModels
            .filter(\.isSelected)
            .map(\.id)
    }

}
