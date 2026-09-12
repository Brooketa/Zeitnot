#if os(Android)
import CJNI
import Shared

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeCreate")
public nonisolated func gameCreate(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ baseMinutes: jint,
    _ incrementSeconds: jint
) -> jlong {
    MainActor.assumeIsolated {
        let service = GameService(
            timeControl: TimeControl(baseMinutes: Int(baseMinutes), incrementSeconds: Int(incrementSeconds)),
            timeSource: ContinuousClock(),
            ticker: Ticker())

        return jlong(Int(bitPattern: Unmanaged.passRetained(service).toOpaque()))
    }
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeDestroy")
public nonisolated func gameDestroy(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return }

    Unmanaged<GameService>.fromOpaque(pointer).release()
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeSnapshot")
public nonisolated func gameSnapshot(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jlongArray? {
    let values = MainActor.assumeIsolated { () -> [jlong] in
        guard let snapshot = service(handle)?.snapshot else { return [] }

        return snapshot.bridgedValues
    }

    return longArray(values, in: environment)
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeReading")
public nonisolated func gameReading(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ player: jint
) -> jstring? {
    let reading = MainActor.assumeIsolated { () -> String? in
        guard let snapshot = service(handle)?.snapshot else { return nil }

        return snapshot[player.bridgedPlayer].remaining.timeReading
    }

    guard let reading else { return nil }

    return string(reading, in: environment)
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativePress")
public nonisolated func gamePress(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ player: jint
) {
    MainActor.assumeIsolated {
        service(handle)?.press(player.bridgedPlayer)
    }
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativePause")
public nonisolated func gamePause(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        service(handle)?.pause()
    }
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeResume")
public nonisolated func gameResume(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        service(handle)?.resume()
    }
}

@_cdecl("Java_com_zeitnot_android_bridge_GameService_nativeReset")
public nonisolated func gameReset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        service(handle)?.reset()
    }
}

private func service(_ handle: jlong) -> GameService? {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return nil }

    return Unmanaged<GameService>.fromOpaque(pointer).takeUnretainedValue()
}

private extension GameSnapshot {

    var bridgedValues: [jlong] {
        [
            white.remaining.milliseconds,
            jlong(white.moveCount),
            jlong(white.status.bridgedValue),
            black.remaining.milliseconds,
            jlong(black.moveCount),
            jlong(black.status.bridgedValue),
            jlong(playerToMove.bridgedValue),
            jlong(moveNumber),
            jlong(winner?.bridgedValue ?? -1),
            jlong(isAwaitingStart ? 1 : 0),
            jlong(isRunning ? 1 : 0),
            jlong(isPaused ? 1 : 0),
            jlong(isFinished ? 1 : 0)
        ]
    }

}

private extension Duration {

    var milliseconds: jlong {
        jlong(components.seconds * 1000 + components.attoseconds / 1_000_000_000_000_000)
    }

}

private extension Player {

    var bridgedValue: Int {
        switch self {
        case .white: 0
        case .black: 1
        }
    }

}

private extension ClockStatus {

    var bridgedValue: Int {
        switch self {
        case .awaitingStart: 0
        case .toMove: 1
        case .lowTime: 2
        case .waiting: 3
        case .flagged: 4
        }
    }

}

private extension jint {

    var bridgedPlayer: Player {
        self == 1 ? .black : .white
    }

}

#endif
