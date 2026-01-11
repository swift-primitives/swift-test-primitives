//
//  Test.Expectation.Failure.swift
//  swift-test-primitives
//
//  Structured expectation failure details.
//

extension Test.Expectation {
    /// Details about why an expectation failed.
    ///
    /// `Failure` is a structured description of an expectation failure,
    /// NOT an Error type. It carries diagnostic information for reporting.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let failure = Test.Expectation.Failure(
    ///     message: "Values are not equal",
    ///     expected: .init(capturing: 42),
    ///     actual: .init(capturing: 0),
    ///     difference: .init([
    ///         .init("42", style: .diffRemoved),
    ///         .init(" → ", style: .plain),
    ///         .init("0", style: .diffAdded),
    ///     ])
    /// )
    /// ```
    public struct Failure: Sendable, Hashable, Codable {
        /// A human-readable message describing the failure.
        public let message: Test.Text

        /// The expected value, if applicable.
        public let expected: Test.Expression.Value?

        /// The actual value, if applicable.
        public let actual: Test.Expression.Value?

        /// A structured difference description, if applicable.
        public let difference: Test.Text?

        /// User-provided comment explaining the expectation.
        public let comment: Test.Text?

        /// Creates a failure description.
        ///
        /// - Parameters:
        ///   - message: A human-readable failure message.
        ///   - expected: The expected value, if applicable.
        ///   - actual: The actual value, if applicable.
        ///   - difference: Structured diff, if applicable.
        ///   - comment: User-provided comment, if any.
        public init(
            message: Test.Text,
            expected: Test.Expression.Value? = nil,
            actual: Test.Expression.Value? = nil,
            difference: Test.Text? = nil,
            comment: Test.Text? = nil
        ) {
            self.message = message
            self.expected = expected
            self.actual = actual
            self.difference = difference
            self.comment = comment
        }
    }
}

// MARK: - CustomStringConvertible

extension Test.Expectation.Failure: CustomStringConvertible {
    public var description: String {
        var result = message.plainText

        if let expected, let actual {
            result += " (expected: \(expected.description), actual: \(actual.description))"
        }

        if let comment {
            result += " — \(comment.plainText)"
        }

        return result
    }
}
