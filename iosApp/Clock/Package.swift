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
        .package(name: "CoreUI", path: "../CoreUI"),
        .package(name: "Shared", path: "../../Shared")
    ],
    targets: [
        .target(
            name: "Clock",
            dependencies: ["CoreUI", "Shared"],
            path: "Sources",
            resources: [
                .process("Common/Resources/Localization"),
                .process("Common/Images/Images.xcassets")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ]),
        .testTarget(
            name: "ClockTests",
            dependencies: ["Clock", "Shared"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
