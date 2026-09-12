#if os(Android)
import CJNI

nonisolated func string(_ value: String, in environment: UnsafeMutablePointer<JNIEnv?>) -> jstring? {
    value.withCString { pointer in
        environment.pointee?.pointee.NewStringUTF(environment, pointer)
    }
}

nonisolated func swiftString(_ value: jstring?, in environment: UnsafeMutablePointer<JNIEnv?>) -> String? {
    guard
        let value,
        let characters = environment.pointee?.pointee.GetStringUTFChars(environment, value, nil)
    else { return nil }

    defer { environment.pointee?.pointee.ReleaseStringUTFChars(environment, value, characters) }

    return String(cString: characters)
}
#endif
