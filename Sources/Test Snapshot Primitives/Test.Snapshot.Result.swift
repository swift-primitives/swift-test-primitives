//
//  Test.Snapshot.Result.swift
//  swift-test-primitives
//
//  Snapshot comparison result.
//

extension Test.Snapshot {
    /// Result of a snapshot comparison operation.
    ///
    /// Represents all possible outcomes of comparing a value against
    /// its reference snapshot.
    public enum Result: Sendable {
        /// The snapshot matched the reference.
        ///
        /// Test should pass.
        case matched

        /// A new snapshot was recorded.
        ///
        /// - Parameter path: Path where the snapshot was written.
        ///
        /// Test may pass or fail depending on recording mode.
        case recorded(path: String)

        /// The snapshot differed from the reference.
        ///
        /// - Parameters:
        ///   - diff: Structured description of the difference.
        ///   - referencePath: Path to the reference snapshot file.
        ///
        /// Test should fail.
        case failed(diff: DiffResult, referencePath: String)

        /// No reference snapshot exists and recording is disabled.
        ///
        /// - Parameter path: Expected path where reference should exist.
        ///
        /// Test should fail.
        case missingReference(path: String)

        /// An inline snapshot was recorded to the source file.
        ///
        /// - Parameter sourceFile: Path to the source file that will be rewritten.
        ///
        /// Test should fail with instruction to re-run.
        case recordedInline(sourceFile: String)
    }
}

// MARK: - Properties

extension Test.Snapshot.Result {
    /// Whether this result represents a passing test.
    public var isPassing: Bool {
        switch self {
        case .matched:
            return true
        case .recorded:
            // Recording is typically considered passing (new snapshot created)
            return true
        case .failed, .missingReference, .recordedInline:
            return false
        }
    }

    /// Whether this result represents a failing test.
    public var isFailing: Bool {
        !isPassing
    }
}

// MARK: - Hashable

/// Structural equality: two results are equal when their cases
/// and all associated values compare equal.
extension Test.Snapshot.Result: Hashable {}

// MARK: - CustomStringConvertible

extension Test.Snapshot.Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .matched:
            return "Snapshot matched"
        case .recorded(let path):
            return "Snapshot recorded at: \(path)"
        case .failed(let diff, let referencePath):
            return "Snapshot mismatch (reference: \(referencePath)): \(diff.summary)"
        case .missingReference(let path):
            return "Missing reference snapshot at: \(path)"
        case .recordedInline(let sourceFile):
            return "Inline snapshot recorded in: \(sourceFile). Re-run to assert."
        }
    }
}
