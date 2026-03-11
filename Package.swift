// swift-tools-version: 6.2

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
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-source-primitives"),
        .package(path: "../swift-async-primitives"),
        .package(path: "../swift-sequence-primitives"),
        .package(path: "../swift-sample-primitives"),
        .package(path: "../swift-numeric-primitives"),
        .package(path: "../swift-witness-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Test Primitives Core",
            dependencies: [
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
                .product(name: "Source Primitives", package: "swift-source-primitives"),
                .product(name: "Sample Primitives", package: "swift-sample-primitives"),
                .product(name: "Real Primitives", package: "swift-numeric-primitives"),
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
                    name: "Identity Primitives Test Support",
                    package: "swift-identity-primitives"
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
