// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SupportKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SupportKit",
            targets: ["SupportKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Babu12345/swift-markdown-ui", from: "2.4.0"),
    ],
    targets: [
        .target(
            name: "SupportKit",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ],
            path: "Sources/SupportKit",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "SupportKitTests",
            dependencies: ["SupportKit"],
            path: "Tests/SupportKitTests"
        ),
    ]
)
