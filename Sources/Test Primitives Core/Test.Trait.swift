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
    /// tags, enabled conditions, exclusion, and timed benchmarks.
    public struct Trait: Sendable, Hashable, Codable {
        /// The kind of trait.
        public let kind: Kind

        /// The source location where this trait was applied.
        public let sourceLocation: Source.Location?

        /// Creates a trait.
        ///
        /// - Parameters:
        ///   - kind: The trait kind.
        ///   - sourceLocation: Where this trait was applied.
        public init(
            kind: Kind,
            sourceLocation: Source.Location? = nil
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

    /// Creates a trait for mutual exclusion within the global group.
    ///
    /// - Returns: An exclusive trait.
    public static var exclusive: Self {
        exclusive(group: "__global__")
    }

    /// Creates a trait for mutual exclusion within a specific group.
    ///
    /// - Parameter group: The exclusion group name.
    /// - Returns: An exclusive trait.
    public static func exclusive(group: String) -> Self {
        Self(kind: .exclusive(group))
    }

    /// Creates a trait for measuring test execution time.
    ///
    /// - Parameters:
    ///   - iterations: Number of measurement runs (default: 10).
    ///   - warmup: Number of untimed warmup runs (default: 0).
    ///   - threshold: Optional performance budget.
    ///   - metric: Metric to check against threshold (default: .median).
    /// - Returns: A timed trait.
    public static func timed(
        iterations: Int = 10,
        warmup: Int = 0,
        threshold: Duration? = nil,
        metric: Test.Benchmark.Metric = .median
    ) -> Self {
        Self(kind: .timed(.init(
            iterations: iterations,
            warmup: warmup,
            printResults: true,
            threshold: threshold,
            metric: metric
        )))
    }
}

// MARK: - CustomStringConvertible

extension Test.Trait: CustomStringConvertible {
    public var description: String {
        kind.description
    }
}
