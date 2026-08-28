public protocol GameServiceProtocol {

    var state: GameState { get }

    func start()
    func endTurn()
    func pause()
    func resume()
    func reset()

}
