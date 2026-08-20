import Testing
import Core
@testable import Setup

struct SetupPresenterTests {

    @Test
    func blitzThreePlusTwoIsSelectedInitially() {
        let presenter = SetupPresenter()

        #expect(selectedPresets(of: presenter) == [.blitz3plus2])
    }

    @Test
    func exactlyOneRulesetIsSelectedAtAllTimes() {
        let presenter = SetupPresenter()

        for preset in PresetRuleset.allCases {
            presenter.select(preset)

            #expect(selectedPresets(of: presenter) == [preset])
        }
    }

    @Test
    func selectingARulesetDeselectsAllOthers() {
        let presenter = SetupPresenter()

        presenter.select(.classical90plus30)

        #expect(selectedPresets(of: presenter) == [.classical90plus30])
    }

    @Test
    func selectingTheAlreadySelectedRulesetIsANoOp() {
        let presenter = SetupPresenter()

        presenter.select(.rapid15plus10)
        presenter.select(.rapid15plus10)

        #expect(selectedPresets(of: presenter) == [.rapid15plus10])
    }

    @Test
    func modelsFollowTheCatalogueOrder() {
        let presenter = SetupPresenter()

        #expect(presenter.rulesetModels.map(\.ruleset) == PresetRuleset.allCases)
    }

    @Test
    func startGameModelCarriesTheSelectedRuleset() {
        let presenter = SetupPresenter()

        #expect(presenter.startGameModel.category == "Blitz")
        #expect(presenter.startGameModel.timeControl == TimeControl(baseMinutes: 3, incrementSeconds: 2))
    }

    @Test
    func startGameModelFollowsTheSelection() {
        let presenter = SetupPresenter()

        presenter.select(.classical90plus30)

        #expect(presenter.startGameModel.category == "Classical")
        #expect(presenter.startGameModel.timeControl == TimeControl(baseMinutes: 90, incrementSeconds: 30))
    }

    @Test
    func gameConfigurationCarriesTheSelectedRuleset() {
        let presenter = SetupPresenter()

        presenter.select(.rapid15plus10)

        #expect(presenter.gameConfiguration.timeControl == TimeControl(baseMinutes: 15, incrementSeconds: 10))
        #expect(presenter.gameConfiguration.category == "Rapid")
    }

    @Test
    func gameConfigurationIsASnapshotOfTheSelectionAtTheTimeItIsRead() {
        let presenter = SetupPresenter()

        presenter.select(.bullet1plus0)
        let configuration = presenter.gameConfiguration
        presenter.select(.classical90plus30)

        #expect(configuration.timeControl == TimeControl(baseMinutes: 1, incrementSeconds: 0))
    }

    private func selectedPresets(of presenter: SetupPresenter) -> [PresetRuleset] {
        presenter.rulesetModels
            .filter(\.isSelected)
            .map(\.ruleset)
    }

}
