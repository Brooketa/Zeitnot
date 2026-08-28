// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS("26.5"),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"])
    ],
    targets: [
        .target(
            name: "Core",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ])
    ])
