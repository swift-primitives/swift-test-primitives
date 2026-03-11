//
//  Test.Benchmark.Complexity.Evidence.swift
//  swift-test-primitives
//
//  Complete analytical evidence from measured data.
//

extension Test.Benchmark.Complexity {
    /// Complete analytical evidence from measured complexity data.
    ///
    /// Raw output of the evidence construction algorithm. Contains the
    /// continuous exponent estimate, discrete candidate fits, doubling
    /// ratios, monotonicity assessment, and the original data points.
    ///
    /// This is an evidence-level type — it contains no policy interpretation,
    /// confidence assignment, or classification decisions. Those are applied
    /// by the foundations layer.
    ///
    /// Candidates are sorted by R² in descending order (best fit first).
    public struct Evidence: Sendable {
        /// Continuous effective exponent from log-log regression.
        public let exponent: Exponent

        /// Per-class OLS regression fits, sorted by R² descending.
        public let candidates: [CandidateFit]

        /// Doubling ratios T(nᵢ₊₁)/T(nᵢ) for consecutive size pairs.
        ///
        /// Provides human-intuitive growth indication:
        /// - ratio ≈ 1: O(1)
        /// - ratio ≈ 2: O(n)
        /// - ratio ≈ 4: O(n²)
        /// - ratio ≈ 8: O(n³)
        public let doublingRatios: [Double]

        /// Mann-Kendall monotonicity assessment of durations ordered by size.
        public let monotonicity: Test.Benchmark.Trend

        /// Measured data points: input size and representative duration.
        ///
        /// Sorted by size in ascending order. The duration is the metric
        /// extracted from per-size-point measurements (e.g., median).
        public let points: [(size: Int, metric: Duration)]

        public init(
            exponent: Exponent,
            candidates: [CandidateFit],
            doublingRatios: [Double],
            monotonicity: Test.Benchmark.Trend,
            points: [(size: Int, metric: Duration)]
        ) {
            self.exponent = exponent
            self.candidates = candidates
            self.doublingRatios = doublingRatios
            self.monotonicity = monotonicity
            self.points = points
        }
    }
}
