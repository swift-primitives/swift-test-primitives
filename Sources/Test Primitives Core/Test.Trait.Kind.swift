//
//  Test.Trait.Kind.swift
//  swift-test-primitives
//
//  Trait categories.
//

extension Test.Trait {
    /// Categories of test traits.
    public enum Kind: Sendable, Hashable, Codable {
        /// A time limit for test execution.
        case timeLimit(Duration)

        /// A tag for filtering and categorization.
        case tag(String)

        /// Whether the test is enabled, with optional reason.
        case enabled(Bool, Test.Text?)

        /// A reference to a bug tracker issue.
        case bug(String, Test.Text?)

        /// The test must run serially (not in parallel).
        case serialized

        /// A custom trait for framework-specific behaviors.
        case custom(String, String?)
    }
}

// MARK: - CustomStringConvertible

extension Test.Trait.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .timeLimit(let duration):
            return ".timeLimit(\(duration))"

        case .tag(let name):
            return ".tag(\"\(name)\")"

        case .enabled(let isEnabled, let comment):
            if isEnabled {
                return ".enabled"
            } else if let comment {
                return ".disabled(\"\(comment.plainText)\")"
            } else {
                return ".disabled"
            }

        case .bug(let id, let comment):
            if let comment {
                return ".bug(\"\(id)\", \"\(comment.plainText)\")"
            } else {
                return ".bug(\"\(id)\")"
            }

        case .serialized:
            return ".serialized"

        case .custom(let name, let value):
            if let value {
                return ".custom(\"\(name)\", value: \"\(value)\")"
            } else {
                return ".custom(\"\(name)\")"
            }
        }
    }
}
