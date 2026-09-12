#if os(Android)
import CJNI
import Shared

private final class ClockSession {

    let router = BridgedClockRouter()

    let presenter: ClockPresenter

    init(gameConfiguration: GameConfiguration) {
        presenter = ClockPresenter(
            gameConfiguration: gameConfiguration,
            gameService: GameService(
                timeControl: gameConfiguration.timeControl,
                timeSource: ContinuousClock(),
                ticker: Ticker()),
            router: router)
    }

}

private final class BridgedClockRouter: ClockRoutingProtocol {

    private(set) var didRequestBack = false

    func navigateBack() {
        didRequestBack = true
    }

}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeCreate")
public nonisolated func clockPresenterCreate(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ baseMinutes: jint,
    _ incrementSeconds: jint,
    _ category: jint
) -> jlong {
    MainActor.assumeIsolated {
        let configuration = GameConfiguration(
            timeControl: TimeControl(baseMinutes: Int(baseMinutes), incrementSeconds: Int(incrementSeconds)),
            category: RulesetCategory(bridgedValue: Int(category)))
        let session = ClockSession(gameConfiguration: configuration)

        return jlong(Int(bitPattern: Unmanaged.passRetained(session).toOpaque()))
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeDestroy")
public nonisolated func clockPresenterDestroy(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return }

    Unmanaged<ClockSession>.fromOpaque(pointer).release()
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeMoveNumber")
public nonisolated func clockPresenterMoveNumber(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        jint(presenter(handle)?.headerModel.moveNumber ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeIsRunning")
public nonisolated func clockPresenterIsRunning(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(presenter(handle)?.isCountingDown == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeFaceState")
public nonisolated func clockPresenterFaceState(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ side: jint
) -> jint {
    MainActor.assumeIsolated {
        guard let model = clockFaceModel(handle, side: side) else { return -1 }

        return jint(model.state.bridgedValue)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeReading")
public nonisolated func clockPresenterReading(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ side: jint
) -> jstring? {
    let reading = MainActor.assumeIsolated { () -> String? in
        guard case let .digital(model)? = clockFaceModel(handle, side: side)?.timeDisplay else { return nil }

        return model.reading
    }

    guard let reading else { return nil }

    return string(reading, in: environment)
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeMinuteDegrees")
public nonisolated func clockPresenterMinuteDegrees(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ side: jint
) -> jdouble {
    MainActor.assumeIsolated {
        jdouble(hands(handle, side: side)?.minuteDegrees ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeSecondDegrees")
public nonisolated func clockPresenterSecondDegrees(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ side: jint
) -> jdouble {
    MainActor.assumeIsolated {
        jdouble(hands(handle, side: side)?.secondDegrees ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeCanPause")
public nonisolated func clockPresenterCanPause(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(presenter(handle)?.controlBarModel.canPause == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeCanReset")
public nonisolated func clockPresenterCanReset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(presenter(handle)?.controlBarModel.canReset == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeShowPauseDialog")
public nonisolated func clockPresenterShowPauseDialog(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(presenter(handle)?.showPauseDialog == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeShowResetDialog")
public nonisolated func clockPresenterShowResetDialog(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(presenter(handle)?.showResetDialog == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativePauseDialogPlayer")
public nonisolated func clockPresenterPauseDialogPlayer(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        guard let model = presenter(handle)?.pauseDialogModel else { return -1 }

        return jint(model.playerToMove == .white ? 0 : 1)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeDisplayMode")
public nonisolated func clockPresenterDisplayMode(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        jint(presenter(handle)?.displayMode == .analog ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeSetDisplayMode")
public nonisolated func clockPresenterSetDisplayMode(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ mode: jint
) {
    MainActor.assumeIsolated {
        presenter(handle)?.displayMode = mode == 1 ? .analog : .digital
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativePress")
public nonisolated func clockPresenterPress(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ side: jint
) {
    MainActor.assumeIsolated {
        presenter(handle)?.press(side == 1 ? .black : .white)
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativePause")
public nonisolated func clockPresenterPause(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.pause()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeResume")
public nonisolated func clockPresenterResume(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.resume()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeReset")
public nonisolated func clockPresenterReset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.reset()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeConfirmReset")
public nonisolated func clockPresenterConfirmReset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.confirmReset()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeCancelReset")
public nonisolated func clockPresenterCancelReset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.cancelReset()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeNavigateBack")
public nonisolated func clockPresenterNavigateBack(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        presenter(handle)?.navigateBack()
    }
}

@_cdecl("Java_com_zeitnot_android_ClockPresenterNative_nativeDidRequestBack")
public nonisolated func clockPresenterDidRequestBack(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(session(handle)?.router.didRequestBack == true ? 1 : 0)
    }
}

private func session(_ handle: jlong) -> ClockSession? {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return nil }

    return Unmanaged<ClockSession>.fromOpaque(pointer).takeUnretainedValue()
}

private func presenter(_ handle: jlong) -> ClockPresenter? {
    session(handle)?.presenter
}

private func clockFaceModel(_ handle: jlong, side: jint) -> ClockFaceModel? {
    guard let clocks = presenter(handle)?.clocksModel else { return nil }

    return side == 1 ? clocks.black : clocks.white
}

private func hands(_ handle: jlong, side: jint) -> DialHands? {
    guard case let .analog(model)? = clockFaceModel(handle, side: side)?.timeDisplay else { return nil }

    return model.hands
}

private extension ClockFaceState {

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

private extension RulesetCategory {

    init(bridgedValue: Int) {
        switch bridgedValue {
        case 1: self = .blitz
        case 2: self = .rapid
        case 3: self = .classical
        default: self = .bullet
        }
    }

}
#endif
