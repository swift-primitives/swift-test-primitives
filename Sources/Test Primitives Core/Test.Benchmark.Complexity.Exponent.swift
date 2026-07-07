//
//  Test.Benchmark.Complexity.Exponent.swift
//  swift-test-primitives
//
//  Continuous effective exponent from log-log regression.
//

import Sample_Primitives

extension Test.Benchmark.Complexity {
    /// Continuous effective exponent from log-log regression.
    ///
    /// The primary analytical output of complexity estimation. Given
    /// measurements at multiple input sizes, log-log regression fits
    /// log₂(T) = k·log₂(n) + log₂(c), yielding:
    ///
    /// - ``value``: the effective exponent k (for example, k ≈ 1.0 for O(n), k ≈ 2.0 for O(n²))
    /// - ``coefficient``: the scale factor c in T ≈ c·nᵏ
    /// - ``fit``: the underlying regression fit with R² and MSE
    ///
    /// The exponent is base-independent (log₂ is used for intuitive
    /// doubling-ratio semantics, but k is the same in any base).
    public struct Exponent: Sendable, Hashable {
        /// The effective power-law exponent k where T ≈ c·nᵏ.
        ///
        /// Approximate interpretation:
        /// - k ≈ 0: O(1)
        /// - k ≈ 0.5: O(√n)
        /// - k ≈ 1.0: O(n) or O(n log n)
        /// - k ≈ 2.0: O(n²)
        /// - k ≈ 3.0: O(n³)
        public let value: Double

        /// The scale factor c in T ≈ c·nᵏ.
        public let coefficient: Double

        /// The underlying log-log regression fit.
        public let fit: Sample.Regression.Fit

        /// Creates an exponent summary from its regression-derived components.
        public init(
            value: Double,
            coefficient: Double,
            fit: Sample.Regression.Fit
        ) {
            self.value = value
            self.coefficient = coefficient
            self.fit = fit
        }
    }
}
