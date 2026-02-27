//
//  Test.Issue.swift
//  swift-test-primitives
//
//  Neutral issue carrier for test problems.
//

extension Test {
    /// A problem encountered during test execution.
    ///
    /// `Issue` is a neutral carrier for any problem that occurred during
    /// a test, including expectation failures, thrown errors, time limit
    /// violations, and more.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let issue = Test.Issue(
    ///     kind: .expectationFailed(expectation.id),
    ///     sourceLocation: expectation.expression.sourceLocation,
    ///     isKnown: false
    /// )
    /// ```
    ///
    /// ## Known Issues
    ///
    /// An issue can be marked as "known" if it matches a known issue
    /// declaration. Known issues don't cause test failure.
    public struct Issue: Sendable, Hashable, Codable {
        /// The category of this issue.
        public let kind: Kind

        /// Where this issue occurred in source code.
        public let sourceLocation: Source.Location?

        /// Whether this is a known issue (won't cause test failure).
        public let isKnown: Bool

        /// Additional context about the issue.
        public let context: Test.Text?

        /// Creates an issue.
        ///
        /// - Parameters:
        ///   - kind: The issue category.
        ///   - sourceLocation: Where the issue occurred.
        ///   - isKnown: Whether this is a known issue.
        ///   - context: Additional context.
        public init(
            kind: Kind,
            sourceLocation: Source.Location? = nil,
            isKnown: Bool = false,
            context: Test.Text? = nil
        ) {
            self.kind = kind
            self.sourceLocation = sourceLocation
            self.isKnown = isKnown
            self.context = context
        }
    }
}

// MARK: - CustomStringConvertible

extension Test.Issue: CustomStringConvertible {
    public var description: String {
        var result = kind.description

        if let sourceLocation {
            result += " at \(sourceLocation)"
        }

        if isKnown {
            result += " (known)"
        }

        if let context {
            result += ": \(context.plainText)"
        }

        return result
    }
}
