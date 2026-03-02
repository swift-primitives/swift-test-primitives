//
//  Test.Attachment.Collector.swift
//  swift-test-primitives
//
//  Thread-safe accumulator for test attachments.
//

import Synchronization

extension Test.Attachment {
    /// Thread-safe accumulator for test attachments.
    ///
    /// Assertion functions record attachments on failure. CI integrations
    /// drain the collector after test execution to surface artifacts.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Record during test execution:
    /// Test.Attachment.collector.record(
    ///     .init(name: "diff.txt", string: diffOutput)
    /// )
    ///
    /// // Drain after tests complete:
    /// let attachments = Test.Attachment.collector.drain()
    /// for attachment in attachments {
    ///     ciSystem.upload(attachment.name, data: attachment.bytes)
    /// }
    /// ```
    public final class Collector: @unchecked Sendable {
        private let _storage = Mutex<[Test.Attachment]>([])

        public init() {}

        /// Records an attachment.
        ///
        /// - Parameter attachment: The attachment to record.
        public func record(_ attachment: Test.Attachment) {
            _storage.withLock { $0.append(attachment) }
        }

        /// Drains all accumulated attachments, clearing storage.
        ///
        /// - Returns: All attachments recorded since the last drain.
        public func drain() -> [Test.Attachment] {
            _storage.withLock {
                let result = $0
                $0 = []
                return result
            }
        }

        /// Whether any attachments have been recorded.
        public var isEmpty: Bool {
            _storage.withLock { $0.isEmpty }
        }
    }

    /// Global attachment collector.
    public static let collector = Collector()
}
