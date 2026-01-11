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
        // Tier 1 primitive libraries - stdlib + identity-primitives ONLY
        .library(name: "Test Primitives", targets: ["Test_Primitives"]),
    ],
    dependencies: [
        // ONLY swift-identity-primitives for Tagged<>
        // NO swift-tests, NO swift-syntax
        .package(path: "../swift-identity-primitives"),
    ],
    targets: [
        // Current target with Bool CaseIterable extensions
        // Will be expanded with Tier 1 primitive types
        .target(
            name: "Test_Primitives",
            dependencies: [
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
            ],
            path: "Sources/Test Primitives"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
