//
//  Test.Benchmark.Complexity.Class.swift
//  swift-test-primitives
//
//  Named asymptotic complexity classes.
//

import Real_Primitives

extension Test.Benchmark.Complexity {
    /// Named asymptotic complexity classes, ordered by growth rate.
    ///
    /// Each class provides a ``transform(_:)`` function that maps an input
    /// size n to the predictor variable used for discrete candidate fitting.
    /// These are predictor-generation functions for empirical fitting, not
    /// proofs of asymptotic behavior.
    public enum Class: Swift.String, Sendable, Hashable, Codable, CaseIterable, Comparable {
        /// O(1) — constant time.
        case constant

        /// O(log n) — logarithmic.
        case logarithmic

        /// O(√n) — square root.
        case squareRoot

        /// O(n) — linear.
        case linear

        /// O(n log n) — linearithmic.
        case linearithmic

        /// O(n²) — quadratic.
        case quadratic

        /// O(n³) — cubic.
        case cubic

        /// O(2ⁿ) — exponential.
        case exponential

        /// Predictor transform for discrete candidate fitting.
        ///
        /// Maps input size n to the predictor variable f(n) for this
        /// complexity class. Used in OLS regression: T ≈ slope·f(n) + intercept.
        ///
        /// - Parameter n: The input size as a floating-point value.
        /// - Returns: The transformed predictor value f(n).
        public func transform(_ n: Double) -> Double {
            switch self {
            case .constant: 1.0
            case .logarithmic: Double.math.log2(n)
            case .squareRoot: n.squareRoot()
            case .linear: n
            case .linearithmic: n * Double.math.log2(n)
            case .quadratic: n * n
            case .cubic: n * n * n
            case .exponential: Double.math.exp2(n)
            }
        }

        /// The theoretical power-law exponent for this class, if applicable.
        ///
        /// Returns `nil` for classes that are not pure power laws
        /// (logarithmic, linearithmic, exponential).
        public var theoreticalExponent: Double? {
            switch self {
            case .constant: 0.0
            case .logarithmic: nil
            case .squareRoot: 0.5
            case .linear: 1.0
            case .linearithmic: nil
            case .quadratic: 2.0
            case .cubic: 3.0
            case .exponential: nil
            }
        }

        // MARK: - Comparable

        /// Growth rate ordering used for ``Comparable`` conformance.
        var order: Int {
            switch self {
            case .constant: 0
            case .logarithmic: 1
            case .squareRoot: 2
            case .linear: 3
            case .linearithmic: 4
            case .quadratic: 5
            case .cubic: 6
            case .exponential: 7
            }
        }

        /// Orders complexity classes from constant through exponential.
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.order < rhs.order
        }
    }
}
