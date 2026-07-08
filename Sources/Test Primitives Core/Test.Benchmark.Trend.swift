//
//  Test.Benchmark.Trend.swift
//  swift-test-primitives
//
//  Temporal trend analysis result.
//

extension Test.Benchmark {
    /// Temporal trend analysis result for a sequence of duration measurements.
    public struct Trend: Sendable {
        /// Mann-Kendall Z statistic.
        ///
        /// |Z| > 1.96 indicates a statistically significant monotonic trend
        /// at the 95% confidence level.
        public let z: Double

        /// Human-readable interpretation of the trend.
        public let interpretation: Interpretation

        /// Creates a trend result from its Mann-Kendall statistic and interpretation.
        public init(z: Double, interpretation: Interpretation) {
            self.z = z
            self.interpretation = interpretation
        }
    }
}

extension Test.Benchmark.Trend {
    /// Trend direction classification.
    public struct Interpretation: Sendable, Codable, Hashable, CustomStringConvertible {
        /// The raw classification string (`"increasing"`, `"decreasing"`, or `"none"`).
        public let rawValue: Swift.String

        /// Creates an interpretation from its raw classification string.
        public init(rawValue: Swift.String) {
            self.rawValue = rawValue
        }
    }
}

extension Test.Benchmark.Trend.Interpretation {
    /// Z > 1.96 — significant monotonic increase (for example, thermal throttling).
    public static let increasing = Self(rawValue: "increasing")

    /// Z < -1.96 — significant monotonic decrease (for example, caching warmup effect).
    public static let decreasing = Self(rawValue: "decreasing")

    /// |Z| <= 1.96 — no statistically significant trend.
    public static let none = Self(rawValue: "none")

    /// The raw classification string.
    public var description: Swift.String { rawValue }
}
