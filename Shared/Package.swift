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
            targets: ["Shared", "SharedBridge"])
    ],
    targets: [
        .target(
            name: "Shared",
            path: "Sources",
            exclude: ["CJNI", "SharedBridge"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self)
            ]),
        .systemLibrary(name: "CJNI", path: "Sources/CJNI"),
        .target(
            name: "SharedBridge",
            dependencies: [
                "Shared",
                .target(name: "CJNI", condition: .when(platforms: [.android]))
            ],
            path: "Sources/SharedBridge",
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
