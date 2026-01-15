// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-test-primitives-tests",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    dependencies: [
        // Parent package
        .package(path: "../"),
        // Testing framework (depends on swift-test-primitives, but this nested package breaks the cycle)
        .package(path: "../../../swift-foundations/swift-testing"),
    ],
    targets: [
        .testTarget(
            name: "Test Primitives Tests",
            dependencies: [
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Sources/Test Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
