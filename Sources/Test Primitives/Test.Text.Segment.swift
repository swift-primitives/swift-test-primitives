//
//  Test.Text.Segment.swift
//  swift-test-primitives
//
//  A styled segment of text.
//

extension Test.Text {
    /// A segment of text with an associated style.
    ///
    /// Segments allow structured text to carry semantic meaning
    /// that can be rendered differently by various reporters.
    public struct Segment: Sendable, Hashable, Codable {
        /// The text content of this segment.
        public let content: String

        /// The semantic style of this segment.
        public let style: Style

        /// Creates a styled segment.
        ///
        /// - Parameters:
        ///   - content: The text content.
        ///   - style: The semantic style.
        public init(_ content: String, style: Style) {
            self.content = content
            self.style = style
        }
    }
}

// MARK: - Style

extension Test.Text.Segment {
    /// Semantic styles for text segments.
    ///
    /// These styles indicate the meaning of text, not its appearance.
    /// Reporters translate styles to appropriate visual formatting.
    public enum Style: String, Sendable, Hashable, Codable, CaseIterable {
        /// Plain, unstyled text.
        case plain

        /// An identifier (function name, variable name, type name).
        case identifier

        /// A literal value (number, string, boolean).
        case value

        /// A keyword or reserved word.
        case keyword

        /// Punctuation or operators.
        case punctuation

        /// Emphasized text (important information).
        case emphasis

        /// Secondary or less important text.
        case secondary

        /// Success indicator (test passed, expectation met).
        case success

        /// Failure indicator (test failed, expectation not met).
        case failure

        /// Warning indicator (potential issue, deprecated).
        case warning

        /// Difference: text that was added.
        case diffAdded

        /// Difference: text that was removed.
        case diffRemoved

        /// Difference: context around changes.
        case diffContext
    }
}

// MARK: - CustomStringConvertible

extension Test.Text.Segment: CustomStringConvertible {
    public var description: String {
        content
    }
}

// MARK: - ExpressibleByStringLiteral

extension Test.Text.Segment: ExpressibleByStringLiteral {
    /// Creates a plain segment from a string literal.
    public init(stringLiteral value: String) {
        self.init(value, style: .plain)
    }
}
