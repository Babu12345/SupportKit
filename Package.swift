// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SupportKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SupportKit",
            targets: ["SupportKit"]
        ),
    ],
    targets: [
        .target(
            name: "SupportKit",
            dependencies: [],
            path: "Sources/SupportKit"
        ),
        .testTarget(
            name: "SupportKitTests",
            dependencies: ["SupportKit"],
            path: "Tests/SupportKitTests"
        ),
    ]
)
