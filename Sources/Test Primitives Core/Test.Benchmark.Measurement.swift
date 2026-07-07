//
//  Test.Benchmark.Measurement.swift
//  swift-test-primitives
//
//  Statistical performance measurement containing multiple duration samples.
//

import Sample_Primitives

extension Test.Benchmark {
    /// Statistical performance measurement containing multiple duration samples.
    ///
    /// Stores the results of running a performance test multiple times
    /// and provides statistical metrics like median, mean, percentiles,
    /// and standard deviation via a pre-computed ``Sample/Batch``.
    public struct Measurement: Sendable {
        /// All measured durations from individual test iterations.
        public let durations: [Duration]

        /// Pre-computed batch statistics over the durations.
        public let batch: Sample.Batch<Duration>

        /// Creates a measurement from an array of durations.
        public init(durations: [Duration]) {
            self.durations = durations
            self.batch = Sample.Batch(durations)
        }
    }
}

// MARK: - Statistical Accessors

extension Test.Benchmark.Measurement {
    /// Minimum duration across all iterations.
    public var min: Duration {
        batch.min ?? .zero
    }

    /// Maximum duration across all iterations.
    public var max: Duration {
        batch.max ?? .zero
    }

    /// Median duration (50th percentile).
    public var median: Duration {
        batch.median ?? .zero
    }

    /// Average (mean) duration across all iterations.
    public var mean: Duration {
        batch.mean(using: .duration) ?? .zero
    }

    /// 50th percentile duration (same as ``median``).
    public var p50: Duration {
        batch.p50 ?? .zero
    }

    /// 75th percentile duration.
    public var p75: Duration {
        batch.p75 ?? .zero
    }

    /// 90th percentile duration.
    public var p90: Duration {
        batch.p90 ?? .zero
    }

    /// 95th percentile duration.
    public var p95: Duration {
        batch.p95 ?? .zero
    }

    /// 99th percentile duration.
    public var p99: Duration {
        batch.p99 ?? .zero
    }

    /// 99.9th percentile duration.
    public var p999: Duration {
        batch.p999 ?? .zero
    }

    /// Calculate a specific percentile.
    ///
    /// - Parameter p: Percentile to calculate, from 0.0 (minimum) to 1.0 (maximum)
    /// - Returns: Duration at the specified percentile, or `.zero` if no durations
    public func percentile(_ p: Double) -> Duration {
        batch.percentile(p) ?? .zero
    }

    /// Standard deviation of duration measurements.
    public var standardDeviation: Duration {
        batch.standardDeviation(using: .duration) ?? .zero
    }

    /// Coefficient of variation as a percentage.
    public var coefficientOfVariation: Double? {
        batch.coefficientOfVariation(using: .duration)
    }

    /// Median Absolute Deviation.
    public var medianAbsoluteDeviation: Duration? {
        batch.medianAbsoluteDeviation
    }

    /// Count of outliers beyond `k × MAD` from the median.
    public func outlierCount(threshold k: Double = 3.0) -> Int? {
        batch.outlierCount(threshold: k)
    }
}

// MARK: - Codable

extension Test.Benchmark.Measurement: Codable {
    private enum CodingKeys: Swift.String, CodingKey {
        case durations
    }

    // reason: signature forced by external protocol Swift.Encodable —
    // encode(to:) requires untyped throws and an existential encoder.
    // swiftlint:disable no_any_protocol_existential typed_throws_required
    /// Encodes the raw durations this measurement was built from.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(durations, forKey: .durations)
    }
    // swiftlint:enable no_any_protocol_existential typed_throws_required

    // reason: signature forced by external protocol Swift.Decodable —
    // init(from:) requires untyped throws and an existential decoder.
    // swiftlint:disable no_any_protocol_existential typed_throws_required
    /// Decodes a measurement, rebuilding the derived batch from the raw durations.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let durations = try container.decode([Duration].self, forKey: .durations)
        self.durations = durations
        self.batch = Sample.Batch(durations)
    }
    // swiftlint:enable no_any_protocol_existential typed_throws_required
}

// MARK: - Comparable

extension Test.Benchmark.Measurement: Comparable {
    /// Compares measurements by median duration.
    public static func < (
        lhs: Test.Benchmark.Measurement,
        rhs: Test.Benchmark.Measurement
    ) -> Bool {
        lhs.median < rhs.median
    }

    /// Compares measurements by median duration.
    public static func == (
        lhs: Test.Benchmark.Measurement,
        rhs: Test.Benchmark.Measurement
    ) -> Bool {
        lhs.median == rhs.median
    }
}

// MARK: - Metric Extraction

extension Sample.Metric {
    /// Extracts this metric from a benchmark measurement.
    @inlinable
    public func extract(from measurement: Test.Benchmark.Measurement) -> Duration {
        self.extract(from: measurement.batch, using: .duration) ?? .zero
    }
}
