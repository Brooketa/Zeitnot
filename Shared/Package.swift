// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .iOS("26.5"),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Shared",
            type: .dynamic,
            targets: ["Shared"])
    ],
    targets: [
        .target(
            name: "Shared",
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ]),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ])
    ])
