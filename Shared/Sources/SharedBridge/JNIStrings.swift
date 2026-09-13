#if os(Android)
import CJNI

nonisolated func string(_ value: String, in environment: UnsafeMutablePointer<JNIEnv?>) -> jstring? {
    value.withCString { pointer in
        environment.pointee?.pointee.NewStringUTF(environment, pointer)
    }
}

nonisolated func longArray(_ values: [jlong], in environment: UnsafeMutablePointer<JNIEnv?>) -> jlongArray? {
    guard let array = environment.pointee?.pointee.NewLongArray(environment, jsize(values.count)) else { return nil }

    values.withUnsafeBufferPointer { buffer in
        guard let base = buffer.baseAddress else { return }

        environment.pointee?.pointee.SetLongArrayRegion(environment, array, 0, jsize(values.count), base)
    }

    return array
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
