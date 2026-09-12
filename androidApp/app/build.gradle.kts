import java.io.ByteArrayOutputStream
import javax.inject.Inject

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
}

val sharedPackageDirectory = layout.projectDirectory.dir("../../Shared")

val packagedAbis = mapOf(
    "arm64-v8a" to "aarch64-unknown-linux-android28",
    "x86_64" to "x86_64-unknown-linux-android28")

abstract class SwiftAndroidLibraries @Inject constructor(private val execOperations: ExecOperations) : DefaultTask() {

    @get:Input
    abstract val abis: MapProperty<String, String>

    @get:Input
    abstract val swiftSdk: Property<String>

    @get:Input
    abstract val packagePath: Property<String>

    @get:InputFiles
    abstract val sources: ConfigurableFileCollection

    @get:OutputDirectory
    abstract val jniLibsDirectory: DirectoryProperty

    @TaskAction
    fun buildLibraries() {
        abis.get().forEach { (abi, triple) ->
            build(abi = abi, triple = triple)
        }
    }

    private fun build(abi: String, triple: String) {
        command("swift", "build", "--swift-sdk", triple, "--package-path", packagePath.get())

        val library = File(packagePath.get(), ".build/$triple/debug/libShared.so")

        check(library.isFile) { "swift build produced no libShared.so at ${library.path}" }

        val destination = jniLibsDirectory.get().dir(abi).asFile

        destination.deleteRecursively()
        destination.mkdirs()

        stage(library = library, searchPath = searchPath(triple = triple), destination = destination)
    }

    private fun stage(library: File, searchPath: List<File>, destination: File) {
        val staged = mutableSetOf<String>()
        val pending = ArrayDeque(listOf(library))

        while (pending.isNotEmpty()) {
            val current = pending.removeFirst()

            if (!staged.add(current.name)) continue

            current.copyTo(File(destination, current.name), overwrite = true)

            neededLibraries(current)
                .mapNotNull { name -> searchPath.map { File(it, name) }.firstOrNull { it.isFile } }
                .filter { it.name !in staged }
                .forEach { pending.addLast(it) }
        }
    }

    private fun neededLibraries(library: File): List<String> =
        command("xcrun", "llvm-objdump", "-p", library.path)
            .lineSequence()
            .filter { it.contains("NEEDED") }
            .map { it.substringAfter("NEEDED").trim() }
            .toList()

    private fun searchPath(triple: String): List<File> {
        val configuration = command("swift", "sdk", "configure", "--show-configuration", swiftSdk.get(), triple)
        val runtimeDirectory = File(configuration.value(of = "swiftResourcesPath"), "android")
        val sysrootDirectory = File(
            configuration.value(of = "sdkRootPath"),
            "usr/lib/${triple.substringBefore("-")}-linux-android")

        check(runtimeDirectory.isDirectory) { "no Swift runtime libraries at ${runtimeDirectory.path}" }
        check(sysrootDirectory.isDirectory) { "no Android sysroot libraries at ${sysrootDirectory.path}" }

        return listOf(runtimeDirectory, sysrootDirectory)
    }

    private fun String.value(of: String): String =
        lineSequence()
            .first { it.startsWith("$of:") }
            .substringAfter("$of:")
            .trim()

    private fun command(vararg arguments: String): String {
        val output = ByteArrayOutputStream()

        execOperations.exec {
            commandLine(arguments.toList())
            standardOutput = output
        }

        return output.toString().trim()
    }

}

val buildSharedSwift = tasks.register<SwiftAndroidLibraries>("buildSharedSwift") {
    group = "build"
    description = "Builds Shared for every packaged ABI and stages it with the Swift runtime"

    abis.set(packagedAbis)
    swiftSdk.set(providers.gradleProperty("zeitnot.swiftSdk"))
    packagePath.set(sharedPackageDirectory.asFile.absolutePath)
    sources.from(sharedPackageDirectory.file("Package.swift"), sharedPackageDirectory.dir("Sources"))
}

android {
    namespace = "com.zeitnot.android"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.zeitnot.android"
        minSdk = 28
        targetSdk = 37
        versionCode = 1
        versionName = "1.0"

        ndk {
            abiFilters += packagedAbis.keys
        }
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

val launchActivity = "com.zeitnot.android/.MainActivity"

tasks.register<Exec>("runDebug") {
    group = "application"
    description = "Installs the debug build on the connected device and launches it"

    dependsOn("installDebug")

    commandLine(
        androidComponents.sdkComponents.adb.get().asFile.path,
        "shell", "am", "start", "-W", "-S", "-n", launchActivity)
}

androidComponents {
    onVariants { variant ->
        variant.sources.jniLibs?.addGeneratedSourceDirectory(buildSharedSwift, SwiftAndroidLibraries::jniLibsDirectory)
    }
}

dependencies {
    implementation(project(":core-ui"))

    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.compose.foundation)
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.tooling.preview)
}
