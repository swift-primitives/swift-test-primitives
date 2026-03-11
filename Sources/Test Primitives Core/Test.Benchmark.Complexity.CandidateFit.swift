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

        public init(
            complexity: Class,
            regression: Sample.Regression.Fit
        ) {
            self.complexity = complexity
            self.regression = regression
        }
    }
}
