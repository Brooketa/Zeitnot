// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GameDomain",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.5"),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GameDomain",
            targets: ["GameDomain"])
    ],
    targets: [
        .target(
            name: "GameDomain",
            resources: [
                .process("Resources/Localization")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "GameDomainTests",
            dependencies: ["GameDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ])
    ])
