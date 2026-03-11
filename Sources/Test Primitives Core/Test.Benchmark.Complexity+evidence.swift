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
    ///    where f(n) is the class's predictor transform, plus computes the class's
    ///    effective exponent over the data range via log-log regression of the transform.
    /// 3. **Growth ratios**: computes T(nᵢ₊₁)/T(nᵢ) for consecutive size pairs.
    /// 4. **Mann-Kendall**: assesses monotonicity of durations ordered by size.
    /// 5. **Metric CV**: coefficient of variation of durations across sizes.
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
                growthRatios: [],
                monotonicity: Test.Benchmark.Trend(z: 0, interpretation: .none),
                points: valid.map { (size: $0.size, metric: Duration.seconds($0.seconds)) },
                metricCV: .infinity
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

        // 2. Per-class OLS: T = slope·f(n) + intercept, plus effective exponent.
        let seconds = valid.map(\.seconds)
        var candidates: [CandidateFit] = []
        for cls in classes {
            let transformed = valid.map { cls.transform(Double($0.size)) }
            let fit = Sample.Regression.linear(x: transformed, y: seconds)

            // Effective exponent: log-log slope of the class's transform
            // over the actual data range. Generalizes theoreticalExponent
            // to non-power-law classes (logarithmic, linearithmic).
            var logSizesForExp: [Double] = []
            var logTransformsForExp: [Double] = []
            for i in valid.indices {
                let t = transformed[i]
                if t > 0 {
                    logSizesForExp.append(logX[i])
                    logTransformsForExp.append(Double.math.log2(t))
                }
            }
            let effectiveExp: Double
            if logTransformsForExp.count >= 2 {
                effectiveExp = Sample.Regression.linear(
                    x: logSizesForExp,
                    y: logTransformsForExp
                ).slope
            } else {
                effectiveExp = cls.theoreticalExponent ?? 0
            }

            candidates.append(CandidateFit(
                complexity: cls,
                regression: fit,
                effectiveExponent: effectiveExp
            ))
        }
        candidates.sort { $0.regression.rSquared > $1.regression.rSquared }

        // 3. Growth ratios: T(nᵢ₊₁) / T(nᵢ)
        var growthRatios: [Double] = []
        for i in 1..<valid.count {
            guard valid[i - 1].seconds > 0 else { continue }
            growthRatios.append(valid[i].seconds / valid[i - 1].seconds)
        }

        // 4. Mann-Kendall monotonicity (on durations ordered by size).
        let durations = valid.map { Duration.seconds($0.seconds) }
        let monotonicity = Test.Benchmark.Trend.mannKendall(durations)

        // 5. Metric coefficient of variation.
        let metricCV: Double
        do {
            let mean = seconds.reduce(0, +) / Double(seconds.count)
            if mean > 0 {
                let variance = seconds.reduce(0.0) { $0 + ($1 - mean) * ($1 - mean) }
                    / Double(seconds.count - 1)
                metricCV = variance.squareRoot() / mean
            } else {
                metricCV = .infinity
            }
        }

        return Evidence(
            exponent: exponent,
            candidates: candidates,
            growthRatios: growthRatios,
            monotonicity: monotonicity,
            points: valid.map { (size: $0.size, metric: Duration.seconds($0.seconds)) },
            metricCV: metricCV
        )
    }
}
