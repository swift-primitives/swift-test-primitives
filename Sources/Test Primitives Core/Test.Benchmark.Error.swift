//
//  Test.Benchmark.Error.swift
//  swift-test-primitives
//
//  Errors thrown during performance testing operations.
//

extension Test.Benchmark {
    /// Errors thrown during performance testing operations.
    public enum Error: Swift.Error, Sendable, CustomStringConvertible {
        /// Performance threshold was exceeded.
        case thresholdExceeded(test: Swift.String, metric: Metric, expected: Duration, actual: Duration)

        /// Performance regression exceeded the configured baseline tolerance.
        case regressionDetected(
            test: Swift.String,
            metric: Metric,
            baseline: Duration,
            current: Duration,
            regression: Double,
            tolerance: Double
        )

        /// A human-readable failure message, one rendering per error case.
        public var description: Swift.String {
            switch self {
            case .thresholdExceeded(let test, let metric, let expected, let actual):
                return """
                    Performance threshold exceeded in '\(test)':
                    Expected \(metric): < \(expected.formatted())
                    Actual \(metric): \(actual.formatted())
                    """

            case .regressionDetected(let test, let metric, let baseline, let current, let regression, let tolerance):
                return """
                    Performance regression detected in '\(test)':
                    Baseline \(metric): \(baseline.formatted())
                    Current \(metric): \(current.formatted())
                    Regression: \(regression)x tolerance (\(tolerance))
                    """
            }
        }
    }
}
