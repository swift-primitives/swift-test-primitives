//
//  Test.Benchmark.Configuration.swift
//  swift-test-primitives
//
//  Composed configuration for timed test execution.
//

extension Test.Benchmark {
    /// Composed configuration for timed test execution.
    ///
    /// Combines ``Iteration`` (measurement mechanics) with ``Evaluation``
    /// (result evaluation policy). The `.timed()` trait carries this as a
    /// single value, but the two concerns have distinct owners:
    ///
    /// - **Iteration**: Owned by the measurement call site (`#benchmark` / `measure {}`).
    ///   When no explicit measurement call is present, the trait's iteration
    ///   config serves as the fallback.
    /// - **Evaluation**: Owned by the `.timed()` trait (declaration site).
    ///   Controls threshold enforcement, baseline comparison, and output.
    public struct Configuration: Sendable, Hashable, Codable {
        /// Measurement iteration parameters.
        ///
        /// Used by `.timed()` as fallback when no `#benchmark`/`measure {}` is present.
        /// Overridden by the measurement call site's own iteration parameters when present.
        public var iteration: Iteration

        /// Evaluation policy applied to measurement results.
        public var evaluation: Evaluation

        /// Creates a timed configuration.
        ///
        /// - Parameters:
        ///   - iteration: Measurement iteration parameters.
        ///   - evaluation: Evaluation policy for results.
        public init(
            iteration: Iteration = .init(),
            evaluation: Evaluation = .init()
        ) {
            self.iteration = iteration
            self.evaluation = evaluation
        }
    }
}
