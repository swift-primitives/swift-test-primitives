//
//  Test.Snapshot.Redaction.swift
//  swift-test-primitives
//
//  A transformation applied to a snapshot format before diffing.
//

extension Test.Snapshot {
    /// A transformation applied to a snapshot format before comparison.
    ///
    /// Redactions stabilize snapshots by replacing volatile data (timestamps,
    /// UUIDs, absolute paths) with deterministic placeholders. They compose:
    /// multiple redactions are applied in order, each transforming the output
    /// of the previous one.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let redaction = Test.Snapshot.Redaction<String>(apply: { text in
    ///     text.replacing(/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/, with: "[uuid]")
    /// })
    /// ```
    ///
    /// Redactions are closure-based at L1. Concrete constructors using optics
    /// or tree navigation are provided at L3.
    public struct Redaction<Format: Sendable>: Sendable {
        /// The transformation to apply to the snapshot format.
        public let apply: @Sendable (Format) -> Format

        /// Creates a redaction with the given transformation.
        ///
        /// - Parameter apply: A function that transforms the format, replacing
        ///   volatile content with stable placeholders.
        public init(apply: @escaping @Sendable (Format) -> Format) {
            self.apply = apply
        }
    }
}
