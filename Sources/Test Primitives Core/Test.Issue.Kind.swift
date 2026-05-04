//
//  Test.Issue.Kind.swift
//  swift-test-primitives
//
//  Issue categories.
//

extension Test.Issue {
    /// Categories of issues that can occur during testing.
    ///
    /// Each kind represents a different type of problem that can be
    /// encountered during test execution.
    public enum Kind: Sendable, Hashable, Codable {
        /// An unconditional failure recorded via `Issue.record()`.
        case unconditional(Test.Text)

        /// An expectation failed.
        case expectationFailed(Test.Expectation.ID)

        /// A confirmation count didn't match the expected count.
        case confirmationMiscounted(actual: Int, expected: Int)

        /// An error was thrown during test execution.
        case errorCaught(type: String, description: Test.Text)

        /// The test exceeded its time limit.
        case timeLimitExceeded(limit: Duration)

        /// A known issue was declared but not actually recorded.
        case knownIssueNotRecorded

        /// The testing API was misused.
        case apiMisused(Test.Text)

        /// A system-level issue occurred.
        case system(Test.Text)
    }
}

// MARK: - CustomStringConvertible

extension Test.Issue.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unconditional(let message):
            return "Unconditional failure: \(message.plainText)"

        case .expectationFailed(let id):
            return "Expectation failed (id: \(id.underlying))"

        case .confirmationMiscounted(let actual, let expected):
            return "Confirmation miscounted: expected \(expected), got \(actual)"

        case .errorCaught(let type, let description):
            return "Error caught (\(type)): \(description.plainText)"

        case .timeLimitExceeded(let limit):
            return "Time limit exceeded: \(limit)"

        case .knownIssueNotRecorded:
            return "Known issue was not recorded"

        case .apiMisused(let message):
            return "API misuse: \(message.plainText)"

        case .system(let message):
            return "System error: \(message.plainText)"
        }
    }
}
