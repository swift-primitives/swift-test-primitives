//
//  Test.Attachment.swift
//  swift-test-primitives
//
//  Test artifact attachment for CI visibility.
//

extension Test {
    /// A named data artifact produced during test execution.
    ///
    /// Attachments capture diagnostic information (diffs, snapshots, logs)
    /// that CI systems can surface alongside test results. They are accumulated
    /// via ``Attachment.Collector`` during test execution.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let attachment = Test.Attachment(name: "snapshot-diff.txt", string: diffOutput)
    /// Test.Attachment.collector.record(attachment)
    /// ```
    public struct Attachment: Sendable {
        /// Display name for the attachment.
        public let name: Swift.String

        /// Raw bytes of the attachment content.
        public let bytes: [UInt8]

        /// Optional MIME type (e.g., "text/plain", "image/png").
        public let contentType: Swift.String?

        /// Creates an attachment from raw bytes.
        ///
        /// - Parameters:
        ///   - name: Display name for the attachment.
        ///   - bytes: Raw content bytes.
        ///   - contentType: Optional MIME type.
        public init(
            name: Swift.String,
            bytes: [UInt8],
            contentType: Swift.String? = nil
        ) {
            self.name = name
            self.bytes = bytes
            self.contentType = contentType
        }

        /// Creates a text attachment.
        ///
        /// - Parameters:
        ///   - name: Display name for the attachment.
        ///   - string: Text content (encoded as UTF-8).
        public init(name: Swift.String, string: Swift.String) {
            self.name = name
            self.bytes = Array(string.utf8)
            self.contentType = "text/plain"
        }
    }
}
