//
//  Test.Snapshot.Faceted.swift
//  swift-test-primitives
//
//  Multi-perspective snapshot container.
//

extension Test.Snapshot {
    /// Groups a primary snapshot strategy with named facets for multi-perspective
    /// snapshot testing.
    ///
    /// A faceted snapshot captures the same value through multiple lenses:
    /// a comprehensive primary strategy (typically file-based) and one or more
    /// focused facets (typically inline). This ensures both full fidelity and
    /// readable assertions.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let faceted = Test.Snapshot.Faceted<HTMLDocument>(
    ///     primary: .html,
    ///     facets: [
    ///         ("text", .textContent),
    ///         ("structure", .domStructure),
    ///     ]
    /// )
    /// ```
    ///
    /// The primary strategy produces a comprehensive file-based snapshot.
    /// Each facet produces a focused view suitable for inline assertions.
    public struct Faceted<Value: Sendable>: Sendable {
        /// The comprehensive strategy — typically saved to disk.
        public let primary: Strategy<Value, Swift.String>

        /// Named facets — each a focused view of the same value.
        public let facets: [(name: Swift.String, strategy: Strategy<Value, Swift.String>)]

        /// Creates a faceted snapshot configuration.
        ///
        /// - Parameters:
        ///   - primary: The comprehensive strategy for full-fidelity snapshots.
        ///   - facets: Named strategies for focused views.
        public init(
            primary: Strategy<Value, Swift.String>,
            facets: [(name: Swift.String, strategy: Strategy<Value, Swift.String>)]
        ) {
            self.primary = primary
            self.facets = facets
        }
    }
}
