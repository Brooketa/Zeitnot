import Clock
import Core

struct Dependencies {

    let router = AppRouter()

    func makeClockPresenter(gameConfiguration: GameConfiguration) -> ClockPresenter {
        ClockPresenter(gameConfiguration: gameConfiguration)
    }

}
