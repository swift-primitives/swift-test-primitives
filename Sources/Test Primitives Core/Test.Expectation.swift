//
//  Test.Expectation.swift
//  swift-test-primitives
//
//  Evaluated test expectation.
//

extension Test {
    /// An evaluated expectation from a test assertion.
    ///
    /// `Expectation` captures the result of evaluating `#expect` or `#require`.
    /// It contains the expression that was evaluated and whether it passed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // From: #expect(count == 5)
    /// let expectation = Test.Expectation(
    ///     id: .init(1),
    ///     expression: capturedExpression,
    ///     isPassing: false,
    ///     failure: .init(message: "count (3) != 5")
    /// )
    /// ```
    public struct Expectation: Sendable, Hashable, Codable {
        /// Unique runtime identifier for this expectation.
        public let id: ID

        /// The expression that was evaluated.
        public let expression: Test.Expression

        /// Whether the expectation passed.
        public let isPassing: Bool

        /// Details about the failure, if any.
        public let failure: Failure?

        /// Creates an expectation result.
        ///
        /// - Parameters:
        ///   - id: The unique runtime identifier.
        ///   - expression: The evaluated expression.
        ///   - isPassing: Whether the expectation passed.
        ///   - failure: Failure details if not passing.
        public init(
            id: ID,
            expression: Test.Expression,
            isPassing: Bool,
            failure: Failure? = nil
        ) {
            precondition(
                !isPassing || failure == nil,
                "Passing expectation must not have a failure"
            )
            precondition(
                isPassing || failure != nil,
                "Failing expectation must have a failure reason"
            )
            self.id = id
            self.expression = expression
            self.isPassing = isPassing
            self.failure = failure
        }

        /// Whether the expectation failed.
        public var isFailing: Bool {
            !isPassing
        }
    }
}

// MARK: - ID

extension Test.Expectation {
    /// Opaque runtime identifier for expectation tracking.
    ///
    /// This is a monotonically increasing counter assigned at runtime,
    /// not a semantic identifier. Use `Tagged` for type safety.
    public typealias ID = Tagged<Test.Expectation, UInt64>
}

// MARK: - CustomStringConvertible

extension Test.Expectation: CustomStringConvertible {
    /// A human-readable rendering: a checkmark with the source, or a failure message.
    ///
    /// Keys off `failure` rather than `isPassing` — the initializer's preconditions
    /// guarantee `isPassing == (failure == nil)`, so this avoids a force unwrap.
    public var description: String {
        guard let failure else { return "✓ \(expression.sourceCode)" }
        return "✗ \(expression.sourceCode): \(failure.message)"
    }
}
