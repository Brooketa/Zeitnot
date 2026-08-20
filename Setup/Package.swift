// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Setup",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(
            name: "Setup",
            targets: ["Setup"])
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(name: "CoreUI", path: "../CoreUI")
    ],
    targets: [
        .target(
            name: "Setup",
            dependencies: ["Core", "CoreUI"],
            path: "Sources",
            resources: [.process("Common/Resources/Localization")],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ]),
        .testTarget(
            name: "SetupTests",
            dependencies: ["Setup"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
