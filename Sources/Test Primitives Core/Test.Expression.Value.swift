//
//  Test.Expression.Value.swift
//  swift-test-primitives
//
//  Runtime value summary for captured expressions.
//

extension Test.Expression {
    /// A runtime value captured from an expression.
    ///
    /// `Value` provides a summary of a runtime value without requiring
    /// the actual value to be `Sendable` or `Codable`. The description
    /// is captured at evaluation time.
    ///
    /// ## Example
    ///
    /// For `user.age >= 18`:
    /// - `label`: `"user.age"`
    /// - `stringValue`: `"25"`
    /// - `typeDescription`: `"Int"`
    public struct Value: Sendable, Hashable, Codable {
        /// The label identifying this value (e.g., subexpression text).
        public let label: String?

        /// A string representation of the value (via String(describing:)).
        public let stringValue: String

        /// A string description of the value's type.
        public let typeDescription: String

        /// Whether this value represents a `nil` optional.
        public let isNil: Bool

        /// Creates a value summary.
        ///
        /// - Parameters:
        ///   - label: Optional label for this value.
        ///   - stringValue: String representation of the value.
        ///   - typeDescription: String representation of the type.
        ///   - isNil: Whether the value is nil.
        public init(
            label: String? = nil,
            stringValue: String,
            typeDescription: String,
            isNil: Bool = false
        ) {
            self.label = label
            self.stringValue = stringValue
            self.typeDescription = typeDescription
            self.isNil = isNil
        }

        /// Creates a value summary from any value.
        ///
        /// - Parameters:
        ///   - value: The value to summarize.
        ///   - label: Optional label for this value.
        public init<T>(capturing value: T, label: String? = nil) {
            self.label = label
            self.stringValue = String(describing: value)
            self.typeDescription = String(describing: type(of: value))

            // Check for nil in optionals
            if let optional = value as? any OptionalProtocol {
                self.isNil = optional._isNil
            } else {
                self.isNil = false
            }
        }
    }
}

// MARK: - OptionalProtocol (internal helper)

/// Internal protocol to check if an optional is nil.
protocol OptionalProtocol {
    var _isNil: Bool { get }
}

extension Optional: OptionalProtocol {
    var _isNil: Bool {
        self == nil
    }
}

// MARK: - CustomStringConvertible

extension Test.Expression.Value: CustomStringConvertible {
    public var description: String {
        if let label {
            return "\(label) = \(stringValue)"
        } else {
            return stringValue
        }
    }
}
