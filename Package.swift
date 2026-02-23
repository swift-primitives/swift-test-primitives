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
        .library(name: "Test Primitives", targets: ["Test_Primitives"]),
    ],
    dependencies: [
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-async-primitives"),
    ],
    targets: [
        .target(
            name: "Test_Primitives",
            dependencies: [
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
                .product(name: "Async Primitives", package: "swift-async-primitives"),
            ],
            path: "Sources/Test Primitives"
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
