// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreUI",
    platforms: [
        .iOS("26.5")
    ],
    products: [
        .library(
            name: "CoreUI",
            targets: ["CoreUI"])
    ],
    targets: [
        .target(
            name: "CoreUI",
            resources: [
                .process("Design/Colors/Colors.xcassets")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
