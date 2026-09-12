struct PlayerClocks: Equatable {

    var white: PlayerClock
    var black: PlayerClock

    subscript(player: Player) -> PlayerClock {
        get {
            switch player {
            case .white: white
            case .black: black
            }
        }
        set {
            switch player {
            case .white: white = newValue
            case .black: black = newValue
            }
        }
    }

}
