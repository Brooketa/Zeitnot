#if os(Android)
import CJNI
import Shared

private final class SetupSession {

    let router = BridgedSetupRouter()

    lazy var presenter = SetupPresenter(router: router)

}

private final class BridgedSetupRouter: SetupRoutingProtocol {

    private(set) var requestedConfiguration: GameConfiguration?

    func navigateToClock(gameConfiguration: GameConfiguration) {
        requestedConfiguration = gameConfiguration
    }

}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeCreate")
public nonisolated func setupPresenterCreate(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?
) -> jlong {
    MainActor.assumeIsolated {
        jlong(Int(bitPattern: Unmanaged.passRetained(SetupSession()).toOpaque()))
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeDestroy")
public nonisolated func setupPresenterDestroy(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return }

    Unmanaged<SetupSession>.fromOpaque(pointer).release()
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetCount")
public nonisolated func setupPresenterRulesetCount(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        jint(models(handle).count)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetId")
public nonisolated func setupPresenterRulesetId(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ index: jint
) -> jstring? {
    let identifier = MainActor.assumeIsolated { model(handle, at: index)?.id }

    guard let identifier else { return nil }

    return string(identifier, in: environment)
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetCategory")
public nonisolated func setupPresenterRulesetCategory(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ index: jint
) -> jint {
    MainActor.assumeIsolated {
        guard let model = model(handle, at: index) else { return -1 }

        return jint(model.category.bridgedValue)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetBaseMinutes")
public nonisolated func setupPresenterRulesetBaseMinutes(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ index: jint
) -> jint {
    MainActor.assumeIsolated {
        jint(model(handle, at: index)?.baseMinutes ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetIncrementSeconds")
public nonisolated func setupPresenterRulesetIncrementSeconds(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ index: jint
) -> jint {
    MainActor.assumeIsolated {
        jint(model(handle, at: index)?.incrementSeconds ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRulesetIsSelected")
public nonisolated func setupPresenterRulesetIsSelected(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ index: jint
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(model(handle, at: index)?.isSelected == true ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeSelectRuleset")
public nonisolated func setupPresenterSelectRuleset(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong,
    _ id: jstring?
) {
    guard let identifier = swiftString(id, in: environment) else { return }

    MainActor.assumeIsolated {
        session(handle)?.presenter.selectRuleset(id: identifier)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeStartGame")
public nonisolated func setupPresenterStartGame(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) {
    MainActor.assumeIsolated {
        session(handle)?.presenter.startGame()
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeDidRequestClock")
public nonisolated func setupPresenterDidRequestClock(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jboolean {
    MainActor.assumeIsolated {
        jboolean(session(handle)?.router.requestedConfiguration != nil ? 1 : 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRequestedBaseMinutes")
public nonisolated func setupPresenterRequestedBaseMinutes(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        jint(session(handle)?.router.requestedConfiguration?.timeControl.baseMinutes ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRequestedIncrementSeconds")
public nonisolated func setupPresenterRequestedIncrementSeconds(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        jint(session(handle)?.router.requestedConfiguration?.timeControl.incrementSeconds ?? 0)
    }
}

@_cdecl("Java_com_zeitnot_android_SetupPresenterNative_nativeRequestedCategory")
public nonisolated func setupPresenterRequestedCategory(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ handle: jlong
) -> jint {
    MainActor.assumeIsolated {
        guard let category = session(handle)?.router.requestedConfiguration?.category else { return -1 }

        return jint(category.bridgedValue)
    }
}

private func session(_ handle: jlong) -> SetupSession? {
    guard let pointer = UnsafeRawPointer(bitPattern: Int(handle)) else { return nil }

    return Unmanaged<SetupSession>.fromOpaque(pointer).takeUnretainedValue()
}

private func models(_ handle: jlong) -> [RulesetModel] {
    session(handle)?.presenter.rulesetModels ?? []
}

private func model(_ handle: jlong, at index: jint) -> RulesetModel? {
    let models = models(handle)

    guard index >= 0, Int(index) < models.count else { return nil }

    return models[Int(index)]
}

private extension RulesetCategory {

    var bridgedValue: Int {
        switch self {
        case .bullet: 0
        case .blitz: 1
        case .rapid: 2
        case .classical: 3
        }
    }

}
#endif
