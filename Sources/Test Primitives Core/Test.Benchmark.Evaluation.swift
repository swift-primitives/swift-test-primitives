//
//  Test.Benchmark.Evaluation.swift
//  swift-test-primitives
//
//  Evaluation policy for benchmark results.
//

extension Test.Benchmark {
    /// Evaluation policy applied to measurement results.
    ///
    /// Controls what to do with benchmark results: threshold enforcement,
    /// baseline regression detection, metric selection, and output.
    /// Owned by the `.timed()` trait (declaration site).
    public struct Evaluation: Sendable, Hashable, Codable {
        /// Optional performance threshold to enforce.
        ///
        /// When set, the scope provider fails the test if the selected metric
        /// exceeds this duration.
        public var threshold: Duration?

        /// Which statistical metric to evaluate against threshold and baseline.
        public var metric: Metric

        /// Optional tolerance for baseline regression detection.
        ///
        /// When set, the scope provider loads a stored baseline measurement,
        /// compares the current result, and fails if the regression exceeds
        /// this fraction (for example, `0.10` = 10% tolerance).
        public var baselineTolerance: Double?

        /// Whether to track memory allocations per iteration.
        ///
        /// When enabled, the scope provider captures allocation statistics
        /// before and after each iteration and includes the delta in diagnostics.
        public var trackAllocations: Bool

        /// Whether a reporter should print results to console.
        public var printResults: Bool

        /// Creates evaluation policy.
        ///
        /// - Parameters:
        ///   - threshold: Optional performance budget.
        ///   - metric: Metric to check against threshold (default: .median).
        ///   - baselineTolerance: Optional regression tolerance (for example, `0.10` = 10%).
        ///   - trackAllocations: Whether to track memory allocations per iteration.
        ///   - printResults: Whether to print results to console.
        public init(
            threshold: Duration? = nil,
            metric: Metric = .median,
            baselineTolerance: Double? = nil,
            trackAllocations: Bool = false,
            printResults: Bool = true
        ) {
            self.threshold = threshold
            self.metric = metric
            self.baselineTolerance = baselineTolerance
            self.trackAllocations = trackAllocations
            self.printResults = printResults
        }
    }
}
