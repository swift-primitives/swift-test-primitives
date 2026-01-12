//
//  Test.Snapshot.swift
//  swift-test-primitives
//
//  Snapshot testing namespace.
//

extension Test {
    /// Namespace for snapshot testing primitive types.
    ///
    /// Contains types for snapshot comparison and diffing:
    /// - ``Strategy``: How to convert and compare values
    /// - ``Diffing``: Serialization and comparison logic
    /// - ``Recording``: When to record vs compare
    /// - ``Result``: Outcome of a snapshot comparison
    /// - ``DiffResult``: Structured difference description
    ///
    /// All types are `Sendable` and Foundation-free.
    public enum Snapshot {}
}
