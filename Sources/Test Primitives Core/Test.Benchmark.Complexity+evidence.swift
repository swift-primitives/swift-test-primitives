//
//  Test.Benchmark.Complexity+evidence.swift
//  swift-test-primitives
//
//  Pure-math evidence construction from measured data points.
//

import Sample_Primitives
import Real_Primitives

extension Test.Benchmark.Complexity {
    /// Constructs analytical evidence from measured data points.
    ///
    /// This is a pure-math function. It applies no policy, thresholds, or
    /// classification decisions. It produces raw evidence that a higher-level
    /// policy layer can interpret.
    ///
    /// The algorithm:
    /// 1. **Log-log regression**: fits log₂(T) = k·log₂(n) + log₂(c) to
    ///    estimate the effective exponent k.
    /// 2. **Per-class OLS**: for each candidate class, fits T = slope·f(n) + intercept
    ///    where f(n) is the class's predictor transform.
    /// 3. **Doubling ratios**: computes T(nᵢ₊₁)/T(nᵢ) for consecutive size pairs.
    /// 4. **Mann-Kendall**: assesses monotonicity of durations ordered by size.
    ///
    /// - Parameters:
    ///   - points: Measured data points as (input size, representative duration).
    ///     Sizes must be positive. Points with non-positive durations are filtered.
    ///   - classes: Candidate complexity classes to fit against.
    /// - Returns: Complete analytical evidence.
    public static func evidence(
        from points: [(size: Int, metric: Duration)],
        classes: [Class]
    ) -> Evidence {
        let averaging = Sample.Averaging<Duration>.duration

        // Project durations to seconds and sort by size.
        var data = points.map { (size: $0.size, seconds: averaging.project($0.metric)) }
        data.sort { $0.size < $1.size }

        // Filter: both size and seconds must be positive for log-log regression.
        let valid = data.filter { $0.size > 0 && $0.seconds > 0 }

        // Edge case: insufficient data for regression.
        guard valid.count >= 2 else {
            let emptyFit = Sample.Regression.Fit(
                slope: 0, intercept: 0, rSquared: 0, meanSquaredError: 0
            )
            return Evidence(
                exponent: Exponent(value: 0, coefficient: 0, fit: emptyFit),
                candidates: [],
                doublingRatios: [],
                monotonicity: Test.Benchmark.Trend(z: 0, interpretation: .none),
                points: valid.map { (size: $0.size, metric: Duration.seconds($0.seconds)) }
            )
        }

        // 1. Log-log regression: log₂(T) = k·log₂(n) + log₂(c)
        let logX = valid.map { Double.math.log2(Double($0.size)) }
        let logY = valid.map { Double.math.log2($0.seconds) }
        let logLogFit = Sample.Regression.linear(x: logX, y: logY)
        let exponent = Exponent(
            value: logLogFit.slope,
            coefficient: Double.math.exp2(logLogFit.intercept),
            fit: logLogFit
        )

        // 2. Per-class OLS: T = slope·f(n) + intercept
        let seconds = valid.map(\.seconds)
        var candidates: [CandidateFit] = []
        for cls in classes {
            let transformed = valid.map { cls.transform(Double($0.size)) }
            let fit = Sample.Regression.linear(x: transformed, y: seconds)
            candidates.append(CandidateFit(complexity: cls, regression: fit))
        }
        candidates.sort { $0.regression.rSquared > $1.regression.rSquared }

        // 3. Doubling ratios: T(nᵢ₊₁) / T(nᵢ)
        var doublingRatios: [Double] = []
        for i in 1..<valid.count {
            guard valid[i - 1].seconds > 0 else { continue }
            doublingRatios.append(valid[i].seconds / valid[i - 1].seconds)
        }

        // 4. Mann-Kendall monotonicity (on durations ordered by size).
        let durations = valid.map { Duration.seconds($0.seconds) }
        let monotonicity = Test.Benchmark.Trend.mannKendall(durations)

        return Evidence(
            exponent: exponent,
            candidates: candidates,
            doublingRatios: doublingRatios,
            monotonicity: monotonicity,
            points: valid.map { (size: $0.size, metric: Duration.seconds($0.seconds)) }
        )
    }
}
