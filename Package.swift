// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-test-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Sub-targets
        .library(name: "Test Primitives Core", targets: ["Test Primitives Core"]),
        .library(name: "Test Snapshot Primitives", targets: ["Test Snapshot Primitives"]),
        .library(
            name: "Test Primitives Standard Library Integration",
            targets: ["Test Primitives Standard Library Integration"]
        ),

        // MARK: - Umbrella
        .library(name: "Test Primitives", targets: ["Test Primitives"]),

        // MARK: - Test Support
        .library(
            name: "Test Primitives Test Support",
            targets: ["Test Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-source-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-async-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sample-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-numeric-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-witness-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Test Primitives Core",
            dependencies: [
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Source Primitives", package: "swift-source-primitives"),
                .product(name: "Sample Primitives", package: "swift-sample-primitives"),
                .product(name: "Real Primitives", package: "swift-numeric-primitives"),
                .product(name: "Time Primitives Core", package: "swift-time-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),

        // MARK: - Snapshot
        .target(
            name: "Test Snapshot Primitives",
            dependencies: [
                "Test Primitives Core",
                .product(name: "Async Primitives", package: "swift-async-primitives"),
                .product(
                    name: "Sequence Difference Primitives",
                    package: "swift-sequence-primitives"
                ),
                .product(name: "Witness Primitives", package: "swift-witness-primitives"),
            ]
        ),

        // MARK: - Standard Library Integration
        .target(
            name: "Test Primitives Standard Library Integration",
            dependencies: [
                "Test Primitives Core",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Test Primitives",
            dependencies: [
                "Test Primitives Core",
                "Test Snapshot Primitives",
                "Test Primitives Standard Library Integration",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Test Primitives Test Support",
            dependencies: [
                "Test Primitives",
                .product(
                    name: "Tagged Primitives Test Support",
                    package: "swift-tagged-primitives"
                ),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Test Primitives Tests",
            dependencies: [
                "Test Primitives",
                "Test Primitives Test Support",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
