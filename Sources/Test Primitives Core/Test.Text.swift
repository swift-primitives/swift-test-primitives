//
//  Test.Text.swift
//  swift-test-primitives
//
//  Structured text with styled segments.
//

extension Test {
    /// Structured text composed of styled segments.
    ///
    /// `Text` provides rich, structured descriptions for test output.
    /// Unlike plain strings, it preserves semantic information about
    /// different parts of the text (identifiers, values, punctuation, and so on).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let text = Test.Text([
    ///     .init("Expected ", style: .plain),
    ///     .init("42", style: .value),
    ///     .init(" but got ", style: .plain),
    ///     .init("0", style: .value),
    /// ])
    /// ```
    ///
    /// ## Rendering
    ///
    /// Reporters can render `Text` differently based on output format:
    /// - Terminal: ANSI colors for different styles
    /// - HTML: CSS classes for styling
    /// - Plain text: Just the raw content
    public struct Text: Sendable, Hashable, Codable {
        /// The segments that compose this text.
        public let segments: [Segment]

        /// Creates structured text from segments.
        ///
        /// - Parameter segments: The segments composing this text.
        public init(_ segments: [Segment]) {
            self.segments = segments
        }

        /// Creates structured text from a single plain string.
        ///
        /// - Parameter string: The plain text content.
        public init(_ string: String) {
            self.segments = [Segment(string, style: .plain)]
        }

        /// The plain text content without styling.
        public var plainText: String {
            segments.map(\.content).joined()
        }

        /// Whether this text is empty (no segments or all segments empty).
        public var isEmpty: Bool {
            segments.allSatisfy { $0.content.isEmpty }
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension Test.Text: ExpressibleByStringLiteral {
    /// Creates plain (unstyled) text from a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - ExpressibleByStringInterpolation

extension Test.Text: ExpressibleByStringInterpolation {
    /// Creates plain (unstyled) text from a string interpolation.
    public init(stringInterpolation: DefaultStringInterpolation) {
        // reason: this IS the bridge — implementing our own
        // ExpressibleByStringInterpolation requires converting the compiler-built
        // `DefaultStringInterpolation` into a `String`, and `String.init(stringInterpolation:)`
        // is the only vocabulary for that; the rule's target (bypassing string-literal
        // syntax) does not apply to a protocol's own conformance implementation.
        // swiftlint:disable:next compiler_protocol_init
        self.init(String(stringInterpolation: stringInterpolation))
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Test.Text: ExpressibleByArrayLiteral {
    /// Creates text from a literal array of styled segments.
    public init(arrayLiteral elements: Segment...) {
        self.init(elements)
    }
}

// MARK: - CustomStringConvertible

extension Test.Text: CustomStringConvertible {
    /// The plain-text rendering, with all styling discarded.
    public var description: String {
        plainText
    }
}

// MARK: - Concatenation

extension Test.Text {
    /// Concatenates two texts.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(lhs.segments + rhs.segments)
    }

    /// Appends another text to this one.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
