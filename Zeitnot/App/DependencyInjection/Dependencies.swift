import Clock
import Core
import Setup

struct Dependencies {

    let router = AppRouter()

    func makeSetupPresenter() -> SetupPresenter {
        SetupPresenter(router: router)
    }

    func makeClockPresenter(gameConfiguration: GameConfiguration) -> ClockPresenter {
        ClockPresenter(gameConfiguration: gameConfiguration)
    }

}
