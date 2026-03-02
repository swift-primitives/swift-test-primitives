//
//  Test.Event.Kind.swift
//  swift-test-primitives
//
//  Event categories.
//

extension Test.Event {
    /// Categories of events that occur during testing.
    public enum Kind: Sendable, Hashable, Codable {
        // MARK: - Run Lifecycle

        /// The test run started.
        case runStarted

        /// The execution plan was created.
        case planCreated

        /// The test run ended.
        case runEnded

        // MARK: - Test Lifecycle

        /// A test started executing.
        case testStarted

        /// A test case started (for parameterized tests).
        case caseStarted(Test.Case)

        /// A test case ended.
        case caseEnded(Test.Case)

        /// A test ended.
        ///
        /// - Parameter result: The test result.
        case testEnded(Result)

        /// A test was skipped.
        ///
        /// - Parameter reason: Why the test was skipped.
        case testSkipped(Test.Text?)

        // MARK: - Assertions

        /// An expectation was checked.
        ///
        /// - Parameter expectation: The evaluated expectation.
        case expectationChecked(Test.Expectation)

        // MARK: - Issues

        /// An issue was recorded.
        ///
        /// - Parameter issue: The recorded issue.
        case issueRecorded(Test.Issue)

        // MARK: - Custom

        /// A custom event for framework extensions.
        ///
        /// - Parameters:
        ///   - name: The event name.
        ///   - payload: Optional string payload.
        case custom(name: String, payload: String?)
    }
}

// MARK: - Result

extension Test.Event {
    /// The result of a test execution.
    public enum Result: Sendable, Hashable, Codable {
        /// The test passed.
        case passed

        /// The test failed.
        case failed

        /// The test was skipped.
        case skipped
    }
}

// MARK: - CustomStringConvertible

extension Test.Event.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .runStarted:
            return "runStarted"

        case .planCreated:
            return "planCreated"

        case .runEnded:
            return "runEnded"

        case .testStarted:
            return "testStarted"

        case .caseStarted(let testCase):
            return "caseStarted(\(testCase.arguments))"

        case .caseEnded(let testCase):
            return "caseEnded(\(testCase.arguments))"

        case .testEnded(let result):
            return "testEnded(\(result))"

        case .testSkipped(let reason):
            if let reason {
                return "testSkipped(\(reason.plainText))"
            } else {
                return "testSkipped"
            }

        case .expectationChecked(let expectation):
            return "expectationChecked(\(expectation.isPassing ? "passed" : "failed"))"

        case .issueRecorded(let issue):
            return "issueRecorded(\(issue.kind))"

        case .custom(let name, let payload):
            if let payload {
                return "custom(\(name): \(payload))"
            } else {
                return "custom(\(name))"
            }
        }
    }
}
