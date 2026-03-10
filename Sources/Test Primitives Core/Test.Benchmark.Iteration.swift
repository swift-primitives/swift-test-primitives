//
//  Test.Benchmark.Iteration.swift
//  swift-test-primitives
//
//  Measurement iteration parameters.
//

extension Test.Benchmark {
    /// Measurement iteration parameters.
    ///
    /// Controls how many times the measured code runs. Owned by the measurement
    /// call site (`#benchmark` / `measure {}`). When the `.timed()` trait is used
    /// without an explicit measurement call, the trait's iteration config serves
    /// as the fallback.
    public struct Iteration: Sendable, Hashable, Codable {
        /// Number of timed measurement runs.
        public var count: Int

        /// Number of untimed warmup runs before measurement begins.
        public var warmup: Int

        /// Creates iteration parameters.
        ///
        /// - Parameters:
        ///   - count: Number of timed measurement runs.
        ///   - warmup: Number of untimed warmup runs.
        public init(
            count: Int = 10,
            warmup: Int = 0
        ) {
            self.count = count
            self.warmup = warmup
        }
    }
}
