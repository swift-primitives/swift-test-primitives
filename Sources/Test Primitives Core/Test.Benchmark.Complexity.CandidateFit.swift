//
//  Test.Benchmark.Complexity.CandidateFit.swift
//  swift-test-primitives
//
//  Per-class regression fit result.
//

import Sample_Primitives

extension Test.Benchmark.Complexity {
    /// Per-class regression fit result.
    ///
    /// Represents the OLS regression T ≈ slope·f(n) + intercept for a
    /// specific complexity class, where f(n) is the class's predictor
    /// ``Class/transform(_:)``.
    public struct CandidateFit: Sendable, Hashable {
        /// The complexity class this fit was computed for.
        public let complexity: Class

        /// The OLS regression fit for this class's predictor transform.
        public let regression: Sample.Regression.Fit

        /// Effective exponent of this class's transform over the data range.
        ///
        /// Computed by log-log regression of the class's predictor transform
        /// values against input sizes. For pure power laws, this equals the
        /// theoretical exponent (e.g., 2.0 for quadratic). For non-power-law
        /// classes, this gives the empirical exponent over the measured range
        /// (e.g., ≈1.05–1.15 for linearithmic over typical benchmark ranges).
        ///
        /// Used for cross-validation: if the observed continuous exponent
        /// diverges from this value, the classification may be unreliable.
        public let effectiveExponent: Double

        public init(
            complexity: Class,
            regression: Sample.Regression.Fit,
            effectiveExponent: Double
        ) {
            self.complexity = complexity
            self.regression = regression
            self.effectiveExponent = effectiveExponent
        }
    }
}
