//
//  Test.Snapshot.Faceted.Result.swift
//  swift-test-primitives
//
//  Aggregate result from a faceted snapshot assertion.
//

extension Test.Snapshot.Faceted {
    /// The aggregate result of a faceted snapshot assertion.
    ///
    /// Contains the primary snapshot result and each facet's result.
    /// The overall assertion passes only when all components pass.
    public struct Result: Sendable {
        /// Result from the primary (comprehensive) strategy.
        public let primary: Test.Snapshot.Result

        /// Results from each named facet.
        public let facets: [(name: Swift.String, result: Test.Snapshot.Result)]

        /// Creates a faceted result.
        ///
        /// - Parameters:
        ///   - primary: Result from the primary strategy.
        ///   - facets: Results from each named facet.
        public init(
            primary: Test.Snapshot.Result,
            facets: [(name: Swift.String, result: Test.Snapshot.Result)]
        ) {
            self.primary = primary
            self.facets = facets
        }
    }
}

extension Test.Snapshot.Faceted.Result {
    /// Whether all components (primary and all facets) are passing.
    public var isPassing: Bool {
        primary.isPassing && facets.allSatisfy { $0.result.isPassing }
    }

    /// Whether any component (primary or any facet) is failing.
    public var isFailing: Bool {
        !isPassing
    }
}
