//
//  Test.Benchmark.Complexity.swift
//  swift-test-primitives
//
//  Namespace for empirical complexity analysis types.
//

extension Test.Benchmark {
    /// Namespace for empirical complexity analysis types.
    ///
    /// Provides the vocabulary for deducing algorithmic complexity from
    /// measured execution times at multiple input sizes. Uses a two-stage
    /// inference model:
    ///
    /// 1. **Continuous estimation**: log-log regression yields an effective
    ///    exponent k where T ≈ c·nᵏ.
    /// 2. **Discrete validation**: per-class OLS regression validates named
    ///    complexity classes (O(n), O(n²), and so on) against the data.
    ///
    /// The types in this namespace are evidence-level primitives (pure math).
    /// Policy interpretation (confidence, compatibility) lives in the
    /// foundations layer.
    ///
    /// - ``Class``: Named asymptotic complexity classes.
    /// - ``Exponent``: Continuous effective exponent from log-log regression.
    /// - ``Candidate/Fit``: Per-class regression fit result.
    /// - ``Evidence``: Complete analytical evidence from measured data.
    public enum Complexity {}
}
