//
//  Test.Benchmark.Configuration.swift
//  swift-test-primitives
//
//  Configuration for timed test execution.
//

extension Test.Benchmark {
    /// Configuration for timed test execution.
    public struct Configuration: Sendable, Hashable {
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

        /// Whether to track memory allocations per iteration.
        ///
        /// When enabled, the scope provider captures `Memory.Allocation.Statistics`
        /// before and after each iteration and includes the delta in diagnostics.
        /// This is inert configuration consumed by higher-layer scope providers.
        public var trackAllocations: Bool

        /// Optional tolerance for baseline regression detection.
        ///
        /// When set, the scope provider loads a stored baseline measurement,
        /// compares the current result, and fails if the regression exceeds
        /// this fraction (e.g. `0.10` = 10% tolerance).
        /// This is inert configuration consumed by higher-layer scope providers.
        public var baselineTolerance: Double?

        /// Creates a timed configuration.
        public init(
            iterations: Int = 10,
            warmup: Int = 0,
            printResults: Bool = true,
            threshold: Duration? = nil,
            metric: Metric = .median,
            trackAllocations: Bool = false,
            baselineTolerance: Double? = nil
        ) {
            self.iterations = iterations
            self.warmup = warmup
            self.printResults = printResults
            self.threshold = threshold
            self.metric = metric
            self.trackAllocations = trackAllocations
            self.baselineTolerance = baselineTolerance
        }
    }
}

// MARK: - Codable

extension Test.Benchmark.Configuration: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
        case iterations
        case warmup
        case printResults
        case threshold
        case metric
        case trackAllocations
        case baselineTolerance
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.iterations = try container.decode(Int.self, forKey: .iterations)
        self.warmup = try container.decode(Int.self, forKey: .warmup)
        self.printResults = try container.decode(Bool.self, forKey: .printResults)
        self.threshold = try container.decodeIfPresent(Duration.self, forKey: .threshold)
        self.metric = try container.decode(Test.Benchmark.Metric.self, forKey: .metric)
        self.trackAllocations = try container.decodeIfPresent(Bool.self, forKey: .trackAllocations) ?? false
        self.baselineTolerance = try container.decodeIfPresent(Double.self, forKey: .baselineTolerance)
    }
}
