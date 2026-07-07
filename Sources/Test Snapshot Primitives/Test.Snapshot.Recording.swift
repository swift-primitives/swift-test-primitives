//
//  Test.Snapshot.Recording.swift
//  swift-test-primitives
//
//  Recording mode enumeration.
//

extension Test.Snapshot {
    /// Controls when snapshots are recorded vs compared.
    ///
    /// Recording modes determine behavior when running snapshot tests:
    ///
    /// | Mode | No Reference | Match | Mismatch |
    /// |------|--------------|-------|----------|
    /// | `.never` | Fail | Pass | Fail |
    /// | `.missing` | Record + Pass | Pass | Fail |
    /// | `.failed` | Record + Pass | Pass | Record + Fail |
    /// | `.all` | Record + Pass | Record + Pass | Record + Pass |
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // CI mode: never record, always compare
    /// @Test(.snapshot(.never))
    /// func testOutput() { ... }
    ///
    /// // Development: record new, compare existing
    /// @Test(.snapshot(.missing))
    /// func testNewFeature() { ... }
    ///
    /// // Update mode: always record
    /// @Test(.snapshot(.all))
    /// func testAfterRefactor() { ... }
    /// ```
    ///
    /// ## Environment Variable
    ///
    /// The `SWIFT_SNAPSHOT_RECORD` environment variable overrides the mode:
    /// - `"all"` → `.all`
    /// - `"missing"` → `.missing`
    /// - `"failed"` → `.failed`
    /// - `"never"` → `.never`
    public enum Recording: String, Sendable, Hashable, Codable, CaseIterable {
        /// Compare only; fail if reference is missing.
        ///
        /// Use in CI environments where snapshots should never be recorded.
        case never

        /// Record if reference is missing; compare if reference exists.
        ///
        /// Default mode for development. New snapshots are recorded automatically,
        /// existing snapshots are compared.
        case missing

        /// Record on failure and still report failure.
        ///
        /// Useful for updating snapshots after intentional changes—run tests,
        /// review recorded snapshots, then re-run to verify.
        case failed

        /// Always record, overwriting existing references.
        ///
        /// Use when regenerating all snapshots after significant changes.
        case all
    }
}

// MARK: - CustomStringConvertible

extension Test.Snapshot.Recording: CustomStringConvertible {
    /// The raw recording-mode string.
    public var description: String { rawValue }
}
