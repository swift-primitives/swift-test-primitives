//
//  Test.Case.swift
//  swift-test-primitives
//
//  Parameterized test case.
//

extension Test {
    /// A parameterized test case.
    ///
    /// When a test is parameterized (e.g., `@Test(arguments: [1, 2, 3])`),
    /// each argument combination creates a separate `Case`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Test(arguments: [1, 2, 3])
    /// func testSquare(value: Int) {
    ///     #expect(value * value > 0)
    /// }
    /// // Creates 3 cases: Case(id: 0, arguments: "1"), etc.
    /// ```
    public struct Case: Sendable, Hashable, Codable {
        /// Unique runtime identifier for this case.
        public let id: ID

        /// String representation of the arguments for this case.
        public let arguments: String

        /// Creates a test case.
        ///
        /// - Parameters:
        ///   - id: The unique runtime identifier.
        ///   - arguments: String representation of arguments.
        public init(id: ID, arguments: String) {
            self.id = id
            self.arguments = arguments
        }
    }
}

// MARK: - ID

extension Test.Case {
    /// Opaque runtime identifier for case tracking.
    ///
    /// This is a monotonically increasing counter assigned at runtime,
    /// not a semantic identifier. Use `Tagged` for type safety.
    public typealias ID = Tagged<Test.Case, UInt64>
}

// MARK: - CustomStringConvertible

extension Test.Case: CustomStringConvertible {
    public var description: String {
        "Case(\(arguments))"
    }
}
