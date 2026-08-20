import Testing
import Core
@testable import Setup

struct SetupPresenterTests {

    @Test
    func blitzThreePlusTwoIsSelectedInitially() {
        let presenter = makePresenter()

        #expect(selectedPresets(of: presenter) == [.blitz3plus2])
    }

    @Test
    func exactlyOneRulesetIsSelectedAtAllTimes() {
        let presenter = makePresenter()

        for preset in PresetRuleset.allCases {
            presenter.select(preset)

            #expect(selectedPresets(of: presenter) == [preset])
        }
    }

    @Test
    func selectingARulesetDeselectsAllOthers() {
        let presenter = makePresenter()

        presenter.select(.classical90plus30)

        #expect(selectedPresets(of: presenter) == [.classical90plus30])
    }

    @Test
    func selectingTheAlreadySelectedRulesetIsANoOp() {
        let presenter = makePresenter()

        presenter.select(.rapid15plus10)
        presenter.select(.rapid15plus10)

        #expect(selectedPresets(of: presenter) == [.rapid15plus10])
    }

    @Test
    func modelsFollowTheCatalogueOrder() {
        let presenter = makePresenter()

        #expect(presenter.rulesetModels.map(\.ruleset) == PresetRuleset.allCases)
    }

    @Test
    func startGameModelCarriesTheSelectedRuleset() {
        let presenter = makePresenter()

        #expect(presenter.startGameModel.category == "Blitz")
        #expect(presenter.startGameModel.timeControl == TimeControl(baseMinutes: 3, incrementSeconds: 2))
    }

    @Test
    func startGameModelFollowsTheSelection() {
        let presenter = makePresenter()

        presenter.select(.classical90plus30)

        #expect(presenter.startGameModel.category == "Classical")
        #expect(presenter.startGameModel.timeControl == TimeControl(baseMinutes: 90, incrementSeconds: 30))
    }

    @Test
    func gameConfigurationCarriesTheSelectedRuleset() {
        let presenter = makePresenter()

        presenter.select(.rapid15plus10)

        #expect(presenter.gameConfiguration.timeControl == TimeControl(baseMinutes: 15, incrementSeconds: 10))
        #expect(presenter.gameConfiguration.category == "Rapid")
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
        #expect(router.routedGameConfigurations.first?.category == "Classical")
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
                    category: "Bullet")])
    }

    @Test
    func startGameLeavesTheSelectionUntouched() {
        let presenter = makePresenter()

        presenter.select(.rapid10plus0)
        presenter.startGame()

        #expect(selectedPresets(of: presenter) == [.rapid10plus0])
    }

    private func makePresenter(router: SetupRoutingProtocol = SetupRoutingSpy()) -> SetupPresenter {
        SetupPresenter(router: router)
    }

    private func selectedPresets(of presenter: SetupPresenter) -> [PresetRuleset] {
        presenter.rulesetModels
            .filter(\.isSelected)
            .map(\.ruleset)
    }

}
