//
//  Test.Benchmark.swift
//  swift-test-primitives
//
//  Namespace for benchmark types.
//

extension Test {
    /// Namespace for benchmark types.
    ///
    /// Contains the core primitives for performance measurement:
    ///
    /// - ``Measurement``: Statistical result of running a benchmark
    /// - ``Iteration``: How many times to measure (call-site config)
    /// - ``Evaluation``: What to do with results (trait config)
    /// - ``Configuration``: Composed iteration + evaluation
    /// - ``Trend``: Mann-Kendall temporal trend analysis
    /// - ``Metric``: Statistical metric selector (typealias for ``Sample/Metric``)
    /// - ``Complexity``: Empirical complexity analysis (exponent, class, evidence)
    public enum Benchmark {}
}

extension Test.Benchmark {
    /// Performance metrics that can be asserted against.
    public typealias Metric = Sample.Metric
}
