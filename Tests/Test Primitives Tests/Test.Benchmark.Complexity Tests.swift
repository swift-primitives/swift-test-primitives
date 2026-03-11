//
//  SUT.Benchmark.Complexity Tests.swift
//  swift-test-primitives
//
//  Unit tests for complexity analysis primitives.
//

import Testing
import Test_Primitives

private typealias SUT = Test_Primitives.Test

@Suite
struct TestBenchmarkComplexityTests {

    @Suite struct Class {}
    @Suite struct Evidence {}
    @Suite struct EdgeCase {}
}

// MARK: - Class

extension TestBenchmarkComplexityTests.Class {

    @Test
    func `comparable ordering matches growth rate`() {
        let classes: [SUT.Benchmark.Complexity.Class] = [
            .constant, .logarithmic, .squareRoot, .linear,
            .linearithmic, .quadratic, .cubic, .exponential,
        ]
        for i in 0..<(classes.count - 1) {
            #expect(classes[i] < classes[i + 1])
        }
    }

    @Test
    func `constant transform returns 1`() {
        #expect(SUT.Benchmark.Complexity.Class.constant.transform(100) == 1.0)
        #expect(SUT.Benchmark.Complexity.Class.constant.transform(1_000_000) == 1.0)
    }

    @Test
    func `linear transform returns n`() {
        #expect(SUT.Benchmark.Complexity.Class.linear.transform(42) == 42.0)
    }

    @Test
    func `quadratic transform returns n squared`() {
        #expect(SUT.Benchmark.Complexity.Class.quadratic.transform(10) == 100.0)
    }

    @Test
    func `theoretical exponents for power laws`() {
        #expect(SUT.Benchmark.Complexity.Class.constant.theoreticalExponent == 0.0)
        #expect(SUT.Benchmark.Complexity.Class.squareRoot.theoreticalExponent == 0.5)
        #expect(SUT.Benchmark.Complexity.Class.linear.theoreticalExponent == 1.0)
        #expect(SUT.Benchmark.Complexity.Class.quadratic.theoreticalExponent == 2.0)
        #expect(SUT.Benchmark.Complexity.Class.cubic.theoreticalExponent == 3.0)
    }

    @Test
    func `non-power-law classes have nil exponent`() {
        #expect(SUT.Benchmark.Complexity.Class.logarithmic.theoreticalExponent == nil)
        #expect(SUT.Benchmark.Complexity.Class.linearithmic.theoreticalExponent == nil)
        #expect(SUT.Benchmark.Complexity.Class.exponential.theoreticalExponent == nil)
    }
}

// MARK: - Evidence (synthetic data)

extension TestBenchmarkComplexityTests.Evidence {

    @Test
    func `linear data produces exponent near 1`() {
        // T(n) = 0.001 * n  (1ms per 1000 elements)
        let sizes = [100, 1_000, 10_000, 100_000]
        let points: [(size: Int, metric: Duration)] = sizes.map { n in
            (size: n, metric: Duration.milliseconds(n / 10))
        }

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.constant, .logarithmic, .linear, .linearithmic, .quadratic]
        )

        #expect(abs(evidence.exponent.value - 1.0) < 0.15)
        #expect(evidence.exponent.fit.rSquared > 0.99)
        #expect(evidence.candidates.first?.complexity == .linear)
        // Mann-Kendall needs > 10 points for significance; with 4 points
        // the z-score may not reach the ±1.96 threshold.
        #expect(
            evidence.monotonicity.interpretation == .increasing
                || evidence.monotonicity.interpretation == .none
        )
    }

    @Test
    func `quadratic data produces exponent near 2`() {
        // T(n) = c * n²
        let sizes = [100, 1_000, 10_000]
        let points: [(size: Int, metric: Duration)] = sizes.map { n in
            let seconds = Double(n) * Double(n) * 1e-9
            return (size: n, metric: Duration.seconds(seconds))
        }

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear, .linearithmic, .quadratic, .cubic]
        )

        #expect(abs(evidence.exponent.value - 2.0) < 0.15)
        #expect(evidence.candidates.first?.complexity == .quadratic)
    }

    @Test
    func `cubic data produces exponent near 3`() {
        let sizes = [10, 100, 1_000]
        let points: [(size: Int, metric: Duration)] = sizes.map { n in
            let seconds = Double(n) * Double(n) * Double(n) * 1e-12
            return (size: n, metric: Duration.seconds(seconds))
        }

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear, .quadratic, .cubic]
        )

        #expect(abs(evidence.exponent.value - 3.0) < 0.15)
        #expect(evidence.candidates.first?.complexity == .cubic)
    }

    @Test
    func `doubling ratios are computed`() {
        let sizes = [100, 200, 400]
        let points: [(size: Int, metric: Duration)] = sizes.map { n in
            (size: n, metric: Duration.milliseconds(n))
        }

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear]
        )

        #expect(evidence.doublingRatios.count == 2)
        #expect(abs(evidence.doublingRatios[0] - 2.0) < 0.01)
        #expect(abs(evidence.doublingRatios[1] - 2.0) < 0.01)
    }

    @Test
    func `candidates sorted by R squared descending`() {
        let sizes = [100, 1_000, 10_000, 100_000]
        let points: [(size: Int, metric: Duration)] = sizes.map { n in
            (size: n, metric: Duration.milliseconds(n / 10))
        }

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.constant, .logarithmic, .linear, .quadratic]
        )

        for i in 0..<(evidence.candidates.count - 1) {
            #expect(
                evidence.candidates[i].regression.rSquared
                    >= evidence.candidates[i + 1].regression.rSquared
            )
        }
    }
}

// MARK: - Edge Case

extension TestBenchmarkComplexityTests.EdgeCase {

    @Test
    func `single point returns degenerate evidence`() {
        let points: [(size: Int, metric: Duration)] = [
            (size: 100, metric: Duration.milliseconds(10)),
        ]

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear]
        )

        #expect(evidence.candidates.isEmpty)
        #expect(evidence.doublingRatios.isEmpty)
        #expect(evidence.exponent.value == 0)
    }

    @Test
    func `zero duration points are filtered`() {
        let points: [(size: Int, metric: Duration)] = [
            (size: 100, metric: .zero),
            (size: 1_000, metric: Duration.milliseconds(10)),
            (size: 10_000, metric: Duration.milliseconds(100)),
            (size: 100_000, metric: Duration.milliseconds(1000)),
        ]

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear]
        )

        // Zero-duration point should be filtered, leaving 3 valid points.
        #expect(evidence.points.count == 3)
    }

    @Test
    func `unsorted input is handled`() {
        let points: [(size: Int, metric: Duration)] = [
            (size: 10_000, metric: Duration.milliseconds(100)),
            (size: 100, metric: Duration.milliseconds(1)),
            (size: 1_000, metric: Duration.milliseconds(10)),
        ]

        let evidence = SUT.Benchmark.Complexity.evidence(
            from: points,
            classes: [.linear]
        )

        // Points should be sorted by size in the output.
        #expect(evidence.points[0].size < evidence.points[1].size)
        #expect(evidence.points[1].size < evidence.points[2].size)
    }
}
