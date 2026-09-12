import Shared

struct Dependencies {

    let router = AppRouter()

    func makeSetupPresenter() -> SetupPresenter {
        SetupPresenter(router: router)
    }

    func makeClockPresenter(gameConfiguration: GameConfiguration) -> ClockPresenter {
        let gameService = GameService(
            timeControl: gameConfiguration.timeControl,
            timeSource: ContinuousClock(),
            ticker: Ticker())

        return ClockPresenter(gameConfiguration: gameConfiguration, gameService: gameService, router: router)
    }

}
