// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Clock",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(
            name: "Clock",
            targets: ["Clock"])
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(name: "CoreUI", path: "../CoreUI")
    ],
    targets: [
        .target(
            name: "Clock",
            dependencies: ["Core", "CoreUI"],
            path: "Sources",
            resources: [.process("Common/Resources/Localization")],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ]),
        .testTarget(
            name: "ClockTests",
            dependencies: ["Clock"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
