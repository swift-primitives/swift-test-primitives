//
//  Test.Event.swift
//  swift-test-primitives
//
//  Neutral event envelope for test execution.
//

public import Identity_Primitives

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

        /// Creates an event.
        ///
        /// - Parameters:
        ///   - id: The test ID, if applicable.
        ///   - caseID: The case ID, if applicable.
        ///   - kind: The event kind.
        ///   - elapsed: Duration since run started.
        public init(
            id: Test.ID? = nil,
            caseID: Test.Case.ID? = nil,
            kind: Kind,
            elapsed: Duration? = nil
        ) {
            self.id = id
            self.caseID = caseID
            self.kind = kind
            self.elapsed = elapsed
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

        if let elapsed {
            parts.append("@\(elapsed)")
        }

        return "Event(\(parts.joined(separator: ", ")))"
    }
}
