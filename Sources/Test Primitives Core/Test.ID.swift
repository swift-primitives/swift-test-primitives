//
//  Test.ID.swift
//  swift-test-primitives
//
//  Composite test identifier.
//

extension Test {
    /// A semantic identifier for a test or suite.
    ///
    /// `Test.ID` is a composite struct containing human-readable components
    /// that uniquely identify a test. Unlike opaque runtime IDs (which use
    /// `Tagged<_, UInt64>`), this ID is designed for:
    /// - Filtering tests by name or module
    /// - Stable ordering across runs
    /// - Human-readable display in reporters
    ///
    /// ## Components
    ///
    /// - `module`: The Swift module containing the test
    /// - `suite`: Optional suite name (nested suites use dot notation)
    /// - `name`: The test function name
    /// - `sourceLocation`: Where the test is defined
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id = Test.ID(
    ///     module: "MyAppTests",
    ///     suite: "AuthenticationTests",
    ///     name: "testLoginSuccess",
    ///     sourceLocation: .init(fileID: #fileID, line: 42, column: 5)
    /// )
    /// ```
    public struct ID: Sendable, Hashable, Codable {
        /// The Swift module containing this test.
        public let module: String

        /// The suite name, if any.
        ///
        /// For nested suites, this may contain dot-separated names
        /// (e.g., "OuterSuite.InnerSuite").
        public let suite: String?

        /// The test function name.
        public let name: String

        /// The source location where this test is defined.
        public let sourceLocation: Source.Location

        /// Creates a test identifier.
        ///
        /// - Parameters:
        ///   - module: The Swift module name.
        ///   - suite: The suite name, or `nil` for top-level tests.
        ///   - name: The test function name.
        ///   - sourceLocation: Where the test is defined.
        public init(
            module: String,
            suite: String? = nil,
            name: String,
            sourceLocation: Source.Location
        ) {
            self.module = module
            self.suite = suite
            self.name = name
            self.sourceLocation = sourceLocation
        }

        /// The fully qualified name of this test.
        ///
        /// Format: `Module.Suite.name` or `Module.name` if no suite.
        public var fullyQualifiedName: String {
            if let suite {
                return "\(module).\(suite).\(name)"
            } else {
                return "\(module).\(name)"
            }
        }
    }
}

// MARK: - Comparable

extension Test.ID: Comparable {
    /// Stable ordering: (module, suite, name, sourceLocation).
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.module != rhs.module {
            return lhs.module < rhs.module
        }
        let lhsSuite = lhs.suite ?? ""
        let rhsSuite = rhs.suite ?? ""
        if lhsSuite != rhsSuite {
            return lhsSuite < rhsSuite
        }
        if lhs.name != rhs.name {
            return lhs.name < rhs.name
        }
        return lhs.sourceLocation < rhs.sourceLocation
    }
}

// MARK: - CustomStringConvertible

extension Test.ID: CustomStringConvertible {
    public var description: String {
        fullyQualifiedName
    }
}
