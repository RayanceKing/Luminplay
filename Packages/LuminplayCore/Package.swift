// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LuminplayCore",
    platforms: [
        .iOS("18.6"),
        .macOS("15.6"),
        .tvOS("18.0"),
        .watchOS("11.0"),
        .visionOS("2.0")
    ],
    products: [
        .library(
            name: "LuminplayCore",
            targets: ["LuminplayCore"]
        )
    ],
    targets: [
        .target(
            name: "LuminplayCore"
        ),
        .testTarget(
            name: "LuminplayCoreTests",
            dependencies: ["LuminplayCore"]
        )
    ]
)
