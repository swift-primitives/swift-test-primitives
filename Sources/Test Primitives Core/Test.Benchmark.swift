//
//  Test.Benchmark.swift
//  swift-test-primitives
//
//  Namespace for benchmark types.
//

extension Test {
    /// Namespace for benchmark types.
    public enum Benchmark {}
}

extension Test.Benchmark {
    /// Performance metrics that can be asserted against.
    public typealias Metric = Sample.Metric
}
