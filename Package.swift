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
        .package(url: "https://github.com/swift-primitives/swift-identity-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-async-primitives.git", from: "0.0.1"),
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

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
