// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Setup",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(
            name: "Setup",
            targets: ["Setup"])
    ],
    dependencies: [
        .package(name: "CoreUI", path: "../CoreUI")
    ],
    targets: [
        .target(
            name: "Setup",
            dependencies: ["CoreUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
