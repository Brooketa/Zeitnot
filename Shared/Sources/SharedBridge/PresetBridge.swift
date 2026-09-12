#if os(Android)
import CJNI
import Shared

@_cdecl("Java_com_zeitnot_android_bridge_PresetCatalogue_nativeCount")
public nonisolated func presetCount(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?
) -> jint {
    jint(PresetRuleset.allCases.count)
}

@_cdecl("Java_com_zeitnot_android_bridge_PresetCatalogue_nativeId")
public nonisolated func presetId(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ index: jint
) -> jstring? {
    guard let preset = preset(at: index) else { return nil }

    return string(preset.id, in: environment)
}

@_cdecl("Java_com_zeitnot_android_bridge_PresetCatalogue_nativeCategory")
public nonisolated func presetCategory(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ index: jint
) -> jint {
    guard let preset = preset(at: index) else { return -1 }

    return jint(preset.category.bridgedValue)
}

@_cdecl("Java_com_zeitnot_android_bridge_PresetCatalogue_nativeBaseMinutes")
public nonisolated func presetBaseMinutes(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ index: jint
) -> jint {
    jint(preset(at: index)?.timeControl.baseMinutes ?? 0)
}

@_cdecl("Java_com_zeitnot_android_bridge_PresetCatalogue_nativeIncrementSeconds")
public nonisolated func presetIncrementSeconds(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?,
    _ index: jint
) -> jint {
    jint(preset(at: index)?.timeControl.incrementSeconds ?? 0)
}

private nonisolated func preset(at index: jint) -> PresetRuleset? {
    let presets = PresetRuleset.allCases

    guard index >= 0, Int(index) < presets.count else { return nil }

    return presets[Int(index)]
}

private nonisolated extension RulesetCategory {

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
