# Android App

The Android app that runs the same Swift logic as the iOS app. Today it proves the toolchain end to
end: it builds `Shared` with the Swift SDK for Android, ships the result inside the APK, and loads it
on launch.

---

## What it does

| On launch | Behaviour |
|---|---|
| `libShared.so` loads | The screen reads `Shared is loaded` |
| `libShared.so` fails to load | The app crashes with an `UnsatisfiedLinkError` |

The failure is deliberate and immediate. A packaging mistake that left a library out would otherwise
surface much later, as a puzzling crash inside a feature.

---

## What ships in the APK

`Shared` is built once per packaged ABI — `arm64-v8a` and `x86_64` — and staged into `jniLibs/`
alongside the native libraries it actually depends on.

Dependencies are followed from `libShared.so` itself, so only what is reachable is packaged:
`libswiftCore.so`, `libswiftObservation.so`, the concurrency and string-processing libraries,
`libdispatch.so` and `libc++_shared.so`. The Swift SDK also ships Foundation, ICU and the testing
libraries; none are reachable from `Shared`, so none are packaged, and the APK stays around 58 MB
rather than 235 MB.

Libraries the platform provides — `libc`, `libm`, `libdl` — are never staged, because they are
resolved on the device.

---

## Building

`assembleDebug` builds the Swift side first; there is no separate step to remember. `runDebug` goes
further and installs the build on the running emulator or attached device, then launches it — one
command from source to a screen.

```
./gradlew :app:assembleDebug     # build only
./gradlew :app:runDebug          # build, install, launch
```

Android Studio needs no setup beyond opening `androidApp/`: it creates the `app` run configuration
itself and the Run button does the same thing.

Requirements on the machine doing the build:

| Needs | Why |
|---|---|
| Swift 6.3 toolchain with the Android SDK installed | Cross-compiles `Shared` |
| Android SDK, API 37, with an emulator or device | Builds and runs the app |
| `local.properties` naming `sdk.dir`, or `ANDROID_HOME` | Tells Gradle where the Android SDK is |

The Swift SDK is named in `gradle.properties` as `zeitnot.swiftSdk`. Its sysroot and runtime paths
are read from the toolchain at build time rather than written down, so installing a different build
of the SDK means changing that one name.
