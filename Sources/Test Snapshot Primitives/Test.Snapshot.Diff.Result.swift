//
//  Test.Snapshot.Diff.Result.swift
//  swift-test-primitives
//
//  Structured difference description.
//

extension Test.Snapshot.Diff {
    /// Result of comparing two values.
    ///
    /// Contains both a summary message and optionally a structured unified diff
    /// using styled ``Test/Text`` with diff-specific styles.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let diff = Test.Snapshot.Diff.Result(
    ///     summary: "3 lines differ",
    ///     unifiedDiff: .init([
    ///         .init("@@ -1,3 +1,3 @@", style: .secondary),
    ///         .init(" context", style: .diffContext),
    ///         .init("-removed", style: .diffRemoved),
    ///         .init("+added", style: .diffAdded),
    ///     ])
    /// )
    /// ```
    public struct Result: Sendable, Hashable, Codable {
        /// A brief summary of the difference.
        ///
        /// Example: "3 lines differ", "Binary content differs at offset 42"
        public let summary: String

        /// Detailed unified diff with styled segments.
        ///
        /// Uses ``Test/Text/Segment/Style/diffAdded``, ``Test/Text/Segment/Style/diffRemoved``,
        /// and ``Test/Text/Segment/Style/diffContext`` for visual formatting.
        public let unifiedDiff: Test.Text?

        /// Structural operations describing individual changes.
        ///
        /// Present when the diffing strategy produces semantic, tree-aware
        /// comparisons (e.g., structural JSON diff). `nil` for line-based diffs.
        public let structuralOperations: [Operation]?

        /// Creates a diff result.
        ///
        /// - Parameters:
        ///   - summary: Brief description of the difference.
        ///   - unifiedDiff: Detailed styled diff, if available.
        ///   - structuralOperations: Structural change operations, if available.
        public init(
            summary: String,
            unifiedDiff: Test.Text? = nil,
            structuralOperations: [Operation]? = nil
        ) {
            self.summary = summary
            self.unifiedDiff = unifiedDiff
            self.structuralOperations = structuralOperations
        }
    }
}

// MARK: - CustomStringConvertible

extension Test.Snapshot.Diff.Result: CustomStringConvertible {
    public var description: String {
        if let diff = unifiedDiff {
            return "\(summary)\n\(diff.plainText)"
        }
        return summary
    }
}
