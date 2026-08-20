import Clock
import Core
import Setup

struct Dependencies {

    let router = AppRouter()

    func makeSetupPresenter() -> SetupPresenter {
        SetupPresenter(router: router)
    }

    func makeClockPresenter(gameConfiguration: GameConfiguration) -> ClockPresenter {
		let gameService = GameService(timeControl: gameConfiguration.timeControl, timeSource: ContinuousClock())

		return ClockPresenter(gameConfiguration: gameConfiguration, gameService: gameService)
    }

}
