public struct GameState: Equatable {

    let phase: Phase
    let white: PlayerClock
    let black: PlayerClock

}

extension GameState {

    enum Phase: Equatable {

        case notStarted
        case running(player: Player)
        case paused(player: Player)
        case finished(winner: Player)

    }

}

extension GameState {

    subscript(player: Player) -> PlayerClock {
        switch player {
        case .white: white
        case .black: black
        }
    }

}
