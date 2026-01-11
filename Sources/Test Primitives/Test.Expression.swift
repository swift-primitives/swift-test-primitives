//
//  Test.Expression.swift
//  swift-test-primitives
//
//  Captured expression for test assertions.
//

public import Identity_Primitives

extension Test {
    /// A captured expression from source code.
    ///
    /// `Expression` captures both the source representation and runtime
    /// value of an expression evaluated during a test assertion.
    ///
    /// ## Example
    ///
    /// For an assertion like `#expect(user.age >= 18)`:
    /// - `sourceCode`: `"user.age >= 18"`
    /// - `values`: Captured subexpressions and their values
    ///
    /// ## Opaque ID
    ///
    /// Each expression instance has a unique `ID` for internal tracking.
    /// This is a `Tagged<Expression, UInt64>` counter, not a semantic identifier.
    public struct Expression: Sendable, Hashable, Codable {
        /// Unique runtime identifier for this expression.
        public let id: ID

        /// The source code representation of this expression.
        public let sourceCode: String

        /// The source location where this expression appears.
        public let sourceLocation: Test.Source.Location

        /// Captured subexpression values.
        public let values: [Value]

        /// Creates a captured expression.
        ///
        /// - Parameters:
        ///   - id: The unique runtime identifier.
        ///   - sourceCode: The source code text.
        ///   - sourceLocation: Where the expression appears.
        ///   - values: Captured subexpression values.
        public init(
            id: ID,
            sourceCode: String,
            sourceLocation: Test.Source.Location,
            values: [Value] = []
        ) {
            self.id = id
            self.sourceCode = sourceCode
            self.sourceLocation = sourceLocation
            self.values = values
        }
    }
}

// MARK: - ID

extension Test.Expression {
    /// Opaque runtime identifier for expression tracking.
    ///
    /// This is a monotonically increasing counter assigned at runtime,
    /// not a semantic identifier. Use `Tagged` for type safety.
    public typealias ID = Tagged<Test.Expression, UInt64>
}

// MARK: - CustomStringConvertible

extension Test.Expression: CustomStringConvertible {
    public var description: String {
        sourceCode
    }
}
