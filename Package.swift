// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Morphed",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Morphed",
            targets: ["Morphed"]
        ),
    ],
    targets: [
        .target(
            name: "Morphed"),
        .testTarget(
            name: "MorphedTests",
            dependencies: ["Morphed"]
        ),
    ]
)
