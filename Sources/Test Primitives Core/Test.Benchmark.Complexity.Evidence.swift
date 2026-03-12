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
    /// continuous exponent estimate, discrete candidate fits, growth
    /// ratios, monotonicity assessment, metric variation, and the
    /// original data points.
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
        public let candidates: [Candidate.Fit]

        /// Growth ratios T(nᵢ₊₁)/T(nᵢ) for consecutive size pairs.
        ///
        /// For geometric sizes with ratio k, the growth ratio approximates
        /// k^exponent for the underlying complexity class:
        /// - O(1): ratio ≈ 1 (independent of k)
        /// - O(n): ratio ≈ k
        /// - O(n²): ratio ≈ k²
        /// - O(n³): ratio ≈ k³
        public let growthRatios: [Double]

        /// Mann-Kendall monotonicity assessment of durations ordered by size.
        public let monotonicity: Test.Benchmark.Trend

        /// Measured data points: input size and representative duration.
        ///
        /// Sorted by size in ascending order. The duration is the metric
        /// extracted from per-size-point measurements (e.g., median).
        public let points: [(size: Int, metric: Duration)]

        /// Coefficient of variation of the metric values across size points.
        ///
        /// A pure statistical fact about the data, not a policy decision.
        /// Low values suggest constant-time behavior:
        /// - CV < 0.02: very likely constant
        /// - CV < 0.05: probably constant
        /// - CV < 0.10: possibly constant
        ///
        /// Returns `.infinity` when fewer than 2 valid points exist.
        public let metricCV: Double

        public init(
            exponent: Exponent,
            candidates: [Candidate.Fit],
            growthRatios: [Double],
            monotonicity: Test.Benchmark.Trend,
            points: [(size: Int, metric: Duration)],
            metricCV: Double
        ) {
            self.exponent = exponent
            self.candidates = candidates
            self.growthRatios = growthRatios
            self.monotonicity = monotonicity
            self.points = points
            self.metricCV = metricCV
        }
    }
}
