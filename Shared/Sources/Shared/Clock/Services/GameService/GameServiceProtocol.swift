public protocol GameServiceProtocol {

    var snapshot: GameSnapshot { get }

    func press(_ player: Player)
    func pause()
    func resume()
    func reset()

}
