//
//  Test.Event.swift
//  swift-test-primitives
//
//  Neutral event envelope for test execution.
//

extension Test {
    /// An event that occurred during test execution.
    ///
    /// `Event` is a neutral envelope that carries information about
    /// what happened during a test run. Events are append-only records
    /// and are NOT Equatable (equality is meaningless for events).
    ///
    /// ## Event Flow
    ///
    /// A typical test run produces events in this order:
    /// 1. `.runStarted` - The test run begins
    /// 2. `.planCreated` - The execution plan is ready
    /// 3. `.testStarted` - A test begins
    /// 4. `.expectationChecked` - An expectation is evaluated
    /// 5. `.issueRecorded` - A problem occurred (if any)
    /// 6. `.testEnded` - A test completes
    /// 7. `.runEnded` - The test run completes
    ///
    /// ## Time
    ///
    /// The `elapsed` field contains a `Duration` offset from run start,
    /// NOT an absolute timestamp. This keeps Tier 1 free of clock dependencies.
    public struct Event: Sendable, Codable {
        /// The test this event relates to, if any.
        public let id: Test.ID?

        /// The test case this event relates to, if any.
        public let caseID: Test.Case.ID?

        /// The kind of event.
        public let kind: Kind

        /// Duration since the run started.
        ///
        /// This is an offset, not an absolute timestamp. `nil` if
        /// the run hasn't started yet or timing is unavailable.
        public let elapsed: Duration?

        // MARK: - Kind-Associated Data

        /// The test result, present when kind is `.testEnded`.
        public let result: Result?

        /// The test case, present when kind is `.caseStarted` or `.caseEnded`.
        public let testCase: Test.Case?

        /// The skip reason, present when kind is `.testSkipped`.
        public let reason: Test.Text?

        /// The expectation, present when kind is `.expectationChecked`.
        public let expectation: Test.Expectation?

        /// The issue, present when kind is `.issueRecorded`.
        public let issue: Test.Issue?

        /// Extensible payload for higher-layer event kinds.
        ///
        /// L1 known kinds use typed properties (result, expectation, etc.).
        /// L3 extensible kinds carry serialized data (e.g. JSON) in payload.
        /// The kind is first-class via Tagged — payload is additional data,
        /// not a kind identifier.
        public let payload: Swift.String?

        /// Creates an event.
        ///
        /// - Parameters:
        ///   - id: The test ID, if applicable.
        ///   - caseID: The case ID, if applicable.
        ///   - kind: The event kind.
        ///   - elapsed: Duration since run started.
        ///   - result: The test result (for `.testEnded`).
        ///   - testCase: The test case (for `.caseStarted`/`.caseEnded`).
        ///   - reason: The skip reason (for `.testSkipped`).
        ///   - expectation: The expectation (for `.expectationChecked`).
        ///   - issue: The issue (for `.issueRecorded`).
        ///   - payload: Extensible payload for higher-layer event kinds.
        public init(
            id: Test.ID? = nil,
            caseID: Test.Case.ID? = nil,
            kind: Kind,
            elapsed: Duration? = nil,
            result: Result? = nil,
            testCase: Test.Case? = nil,
            reason: Test.Text? = nil,
            expectation: Test.Expectation? = nil,
            issue: Test.Issue? = nil,
            payload: Swift.String? = nil
        ) {
            self.id = id
            self.caseID = caseID
            self.kind = kind
            self.elapsed = elapsed
            self.result = result
            self.testCase = testCase
            self.reason = reason
            self.expectation = expectation
            self.issue = issue
            self.payload = payload
        }
    }
}

// MARK: - CustomStringConvertible

extension Test.Event: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []

        if let id {
            parts.append(id.description)
        }

        if let caseID {
            parts.append("case:\(caseID.rawValue)")
        }

        parts.append(kind.description)

        if let result {
            parts.append("\(result)")
        }
        if let testCase {
            parts.append(testCase.arguments)
        }
        if let reason {
            parts.append(reason.plainText)
        }
        if let expectation {
            parts.append(expectation.isPassing ? "passed" : "failed")
        }
        if let issue {
            parts.append("\(issue.kind)")
        }

        if let payload {
            let truncated = payload.count > 64
                ? Swift.String(payload.prefix(64)) + "…"
                : payload
            parts.append("payload:\(truncated)")
        }

        if let elapsed {
            parts.append("@\(elapsed)")
        }

        return "Event(\(parts.joined(separator: ", ")))"
    }
}
