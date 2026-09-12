#if os(Android)
import CJNI

@_cdecl("Java_com_zeitnot_android_SwiftMainQueue_nativeDrain")
public nonisolated func swiftMainQueueDrain(
    _ environment: UnsafeMutablePointer<JNIEnv?>,
    _ caller: jobject?
) {
    _dispatch_main_queue_callback_4CF(nil)
}
#endif
