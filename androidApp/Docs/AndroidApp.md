# Android App

The Android app. It builds `Shared` with the Swift SDK for Android, ships the result inside the APK,
and plays a game through it: pick a preset, start the clock, press a half, pause, reset, flag.

**The shared library is the game, not the screens.** Kotlin holds its own presenters and view models
and reads the domain through a small JNI surface — create and destroy a game, five actions, and a
snapshot read. The formatted time reading comes from `Shared` too, because truncating rather than
rounding is a rule, not a format preference.

## Driving Swift's main queue

Everything in `Shared` is `MainActor`-isolated, and on Android nothing drains libdispatch's main
queue — the main thread is inside the Android `Looper`. Without help, a `Task` enqueued on the
MainActor never runs, which means the ticker never fires and a clock never counts down or flags.

`SwiftMainQueue` fixes that: a Choreographer frame callback drains the main queue once per frame
while the Activity is alive. It is the reason any Swift async works in this app.

---

## What it does

| Screen | Behaviour |
|---|---|
| Setup | Lists the six presets, one selected at a time, and starts a game with it — see `SetupScreen.md` |
| Clock | Two cards that count down, digital or analog, with pause and reset — see `ClockScreen.md` |

A half reads `PRESS TO START` until Black begins, pulses on the accent tint below the warning
threshold, and fills accent with `FLAG FELL` when its clock reaches zero. The running clock advances
and a flag lands with nobody touching the device.

If `libShared.so` is missing or unloadable the app crashes immediately with an `UnsatisfiedLinkError`
rather than degrading — a packaging mistake surfaces at launch instead of much later, inside a
feature.

---

## How the app is put together

The same layering as iOS — **View → Presenter → Service** — written in Kotlin:

```
com.zeitnot.android
├── domain/     GameServiceContract · PresetCatalogueContract · the value types they carry
├── bridge/     GameService · PresetCatalogue · SharedLibrary · SwiftMainQueue
├── clock/      ClockPresenter · ClockScreen
└── setup/      SetupPresenter · SetupScreen
```

**`domain/` holds the abstractions and the values that cross them** — `GameSnapshot`, `ClockSnapshot`,
`ClockStatus`, `Player`, `Preset`, `RulesetCategory`. These are Kotlin mirrors of the Swift types;
they carry data and no rules, so nothing here can disagree with `Shared`.

**`bridge/` is the only place that knows Swift exists.** `GameService` and `PresetCatalogue` hold the
opaque handle and the `external fun` declarations; everything above them talks to a contract. A
presenter cannot tell whether the game is implemented in Swift, which is why a Kotlin fake can stand
in for one.

### An abstraction is a `Contract`

`GameServiceContract` is the interface; `GameService` is the implementation. The naming mirrors
iOS's `GameServiceProtocol` / `GameService` pair with the word Kotlin readers expect, and keeps the
house rule intact: which type is the abstraction is visible at a glance.

### Dependencies are injected

`ClockPresenter(game: GameServiceContract)` and `SetupPresenter(catalogue: PresetCatalogueContract)`
take what they need; the screen composes the implementation and owns its lifetime. A presenter never
constructs its own dependency, and never loads a library.

### The screen pulls; nothing pushes

Compose cannot observe Swift, so a screen reads a fresh model after every action, and — while a game
is running — once per frame. Nothing is read on a schedule when no game is running. This works
because remaining time is derived from a monotonic instant, so any read is correct at the moment it
happens.

The Swift object is invisible to the garbage collector: a screen releases it from a `DisposableEffect`,
and closing twice fails cleanly rather than double-releasing.

---

## Where Android differs from iOS

The design is one design, and the tokens, sizes and copy match. These five things cannot, and are
deliberate rather than oversights:

| Difference | Why |
|---|---|
| The clock dial is **drawn**, not loaded | The iOS artwork is a vector PDF with live text; Android can load neither. The geometry is copied exactly, so a change has to be made in both places. |
| The back control is a plain **surface circle** | iOS uses Liquid Glass, which has no Android equivalent. |
| The card shadow is **approximate** | iOS specifies ink at 12% with a 3pt radius and 1pt offset; Compose shadows are elevation-driven, so 3dp is the closest equivalent rather than the same recipe. |
| Dialogs blur only on **Android 12+** | `Modifier.blur` needs API 31. Below it the dim and fade still happen. |
| Scrolling **stretches** rather than bounces | Overscroll is a platform idiom. An Android app that rubber-bands reads as a port. |

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
