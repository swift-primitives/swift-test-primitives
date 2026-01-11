//
//  Test.Trait.swift
//  swift-test-primitives
//
//  Test trait value type.
//

extension Test {
    /// A trait that modifies test behavior.
    ///
    /// `Trait` is a value type representing test modifiers like time limits,
    /// tags, enabled conditions, and custom behaviors.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let traits: [Test.Trait] = [
    ///     .timeLimit(.seconds(30)),
    ///     .tag("slow"),
    ///     .enabled(if: ProcessInfo.processInfo.environment["CI"] != nil),
    /// ]
    /// ```
    ///
    /// ## Custom Traits
    ///
    /// Use `.custom` to define framework-specific traits that aren't
    /// covered by the built-in kinds.
    public struct Trait: Sendable, Hashable, Codable {
        /// The kind of trait.
        public let kind: Kind

        /// The source location where this trait was applied.
        public let sourceLocation: Test.Source.Location?

        /// Creates a trait.
        ///
        /// - Parameters:
        ///   - kind: The trait kind.
        ///   - sourceLocation: Where this trait was applied.
        public init(
            kind: Kind,
            sourceLocation: Test.Source.Location? = nil
        ) {
            self.kind = kind
            self.sourceLocation = sourceLocation
        }
    }
}

// MARK: - Factory Methods

extension Test.Trait {
    /// Creates a time limit trait.
    ///
    /// - Parameter duration: The maximum duration for the test.
    /// - Returns: A time limit trait.
    public static func timeLimit(_ duration: Duration) -> Self {
        Self(kind: .timeLimit(duration))
    }

    /// Creates a tag trait.
    ///
    /// - Parameter name: The tag name.
    /// - Returns: A tag trait.
    public static func tag(_ name: String) -> Self {
        Self(kind: .tag(name))
    }

    /// Creates an enabled condition trait.
    ///
    /// - Parameters:
    ///   - condition: Whether the test should run.
    ///   - comment: Explanation for why the test is disabled.
    /// - Returns: An enabled trait.
    public static func enabled(if condition: Bool, _ comment: Test.Text? = nil) -> Self {
        Self(kind: .enabled(condition, comment))
    }

    /// Creates a disabled trait.
    ///
    /// - Parameter comment: Explanation for why the test is disabled.
    /// - Returns: A disabled trait.
    public static func disabled(_ comment: Test.Text? = nil) -> Self {
        Self(kind: .enabled(false, comment))
    }

    /// Creates a bug reference trait.
    ///
    /// - Parameters:
    ///   - id: The bug identifier.
    ///   - comment: Additional context.
    /// - Returns: A bug reference trait.
    public static func bug(_ id: String, _ comment: Test.Text? = nil) -> Self {
        Self(kind: .bug(id, comment))
    }

    /// Creates a serial execution trait.
    ///
    /// - Returns: A serial execution trait.
    public static var serialized: Self {
        Self(kind: .serialized)
    }

    /// Creates a custom trait.
    ///
    /// - Parameters:
    ///   - name: The custom trait name.
    ///   - value: Optional string value.
    /// - Returns: A custom trait.
    public static func custom(_ name: String, value: String? = nil) -> Self {
        Self(kind: .custom(name, value))
    }
}

// MARK: - CustomStringConvertible

extension Test.Trait: CustomStringConvertible {
    public var description: String {
        kind.description
    }
}
