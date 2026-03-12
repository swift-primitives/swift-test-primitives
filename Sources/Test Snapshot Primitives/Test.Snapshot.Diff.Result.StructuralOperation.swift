//
//  Test.Snapshot.Diff.Result.StructuralOperation.swift
//  swift-test-primitives
//
//  Format-agnostic representation of a structural change.
//

extension Test.Snapshot.Diff.Result {
    /// A single structural change between two snapshots.
    ///
    /// Provides a format-agnostic, string-based representation of a
    /// diff operation. Useful for programmatic inspection of diff results
    /// by CI systems or test reporters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = Diff.Result(
    ///     summary: "2 changes",
    ///     structuralOperations: [
    ///         .added(path: "email", value: "\"alice@example.com\""),
    ///         .modified(path: "name", old: "\"Alice\"", new: "\"Bob\""),
    ///     ]
    /// )
    /// ```
    public enum StructuralOperation: Sendable, Hashable, Codable {
        /// A value was added at the given path.
        case added(path: Swift.String, value: Swift.String)

        /// A value was removed from the given path.
        case removed(path: Swift.String, value: Swift.String)

        /// A value at the given path changed.
        case modified(path: Swift.String, old: Swift.String, new: Swift.String)
    }
}
