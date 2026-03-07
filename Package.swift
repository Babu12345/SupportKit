// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SupportKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "SupportKit",
            targets: ["SupportKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Babu12345/textual", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "SupportKit",
            dependencies: [
                .product(name: "Textual", package: "textual"),
            ],
            path: "Sources/SupportKit"
        ),
        .testTarget(
            name: "SupportKitTests",
            dependencies: ["SupportKit"],
            path: "Tests/SupportKitTests"
        ),
    ]
)
