// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tapsilat",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Tapsilat",
            targets: ["Tapsilat"]
        ),
    ],
    targets: [
        .target(
            name: "Tapsilat"
        ),
        .testTarget(
            name: "TapsilatTests",
            dependencies: ["Tapsilat"]
        ),
    ]
)
