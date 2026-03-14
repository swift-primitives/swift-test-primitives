//
//  Test.Event.Result.swift
//  swift-test-primitives
//
//  Test execution result.
//

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
