//
//  Test.Benchmark.Configuration.swift
//  swift-test-primitives
//
//  Configuration for timed test execution.
//

extension Test.Benchmark {
    /// Configuration for timed test execution.
    public struct Configuration: Sendable, Codable, Hashable {
        /// Number of measurement iterations.
        public var iterations: Int

        /// Number of warmup iterations (not measured).
        public var warmup: Int

        /// Whether a reporter should print results to console.
        ///
        /// This is inert configuration consumed by higher-layer reporters.
        /// No Tier 1 code reads or acts on this value.
        public var printResults: Bool

        /// Optional performance threshold to enforce.
        public var threshold: Duration?

        /// Metric to check against threshold.
        public var metric: Metric

        /// Creates a timed configuration.
        public init(
            iterations: Int = 10,
            warmup: Int = 0,
            printResults: Bool = true,
            threshold: Duration? = nil,
            metric: Metric = .median
        ) {
            self.iterations = iterations
            self.warmup = warmup
            self.printResults = printResults
            self.threshold = threshold
            self.metric = metric
        }
    }
}
