//
//  Test.Snapshot.Diffing.swift
//  swift-test-primitives
//
//  Serialization and comparison logic.
//

extension Test.Snapshot {
    /// Encapsulates serialization and comparison for a format.
    ///
    /// `Diffing` defines how to:
    /// 1. Serialize a format to bytes for disk storage
    /// 2. Deserialize bytes back to the format
    /// 3. Compare two format values and produce a diff
    ///
    /// ## Built-in Diffing Strategies
    ///
    /// - ``text``: Full text comparison
    /// - ``lines``: Line-by-line comparison with unified diff
    /// - ``data``: Binary byte comparison
    ///
    /// ## Custom Diffing
    ///
    /// ```swift
    /// extension Test.Snapshot.Diffing where Format == MyCustomFormat {
    ///     static var myFormat: Self {
    ///         Diffing(
    ///             toBytes: { format in Array(format.serialize().utf8) },
    ///             fromBytes: { bytes in MyCustomFormat.deserialize(String(decoding: bytes, as: UTF8.self)) },
    ///             diff: { old, new in
    ///                 guard old != new else { return nil }
    ///                 return DiffResult(summary: "Formats differ")
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    public struct Diffing<Format>: Sendable {
        /// Serializes format to bytes for disk storage.
        public let toBytes: @Sendable (Format) -> [UInt8]

        /// Deserializes bytes back to format.
        ///
        /// Returns `nil` if deserialization fails.
        public let fromBytes: @Sendable ([UInt8]) -> Format?

        /// Compares two format values.
        ///
        /// Returns `nil` if values are equal, or a ``DiffResult`` describing the difference.
        public let diff: @Sendable (Format, Format) -> DiffResult?

        /// Creates a diffing strategy.
        ///
        /// - Parameters:
        ///   - toBytes: Serializes format to bytes.
        ///   - fromBytes: Deserializes bytes to format.
        ///   - diff: Compares two values, returning diff if different.
        public init(
            toBytes: @escaping @Sendable (Format) -> [UInt8],
            fromBytes: @escaping @Sendable ([UInt8]) -> Format?,
            diff: @escaping @Sendable (Format, Format) -> DiffResult?
        ) {
            self.toBytes = toBytes
            self.fromBytes = fromBytes
            self.diff = diff
        }
    }
}
