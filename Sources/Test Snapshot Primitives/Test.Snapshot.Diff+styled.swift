//
//  Test.Snapshot.Diff+styled.swift
//  swift-test-primitives
//
//  Styled diff output bridge to Test.Text.
//

extension Test.Snapshot.Diff {
    /// Generates styled ``Test/Text`` from line differences.
    ///
    /// Uses ``Test/Text/Segment/Style/diffAdded``, ``Test/Text/Segment/Style/diffRemoved``,
    /// and ``Test/Text/Segment/Style/diffContext`` styles.
    ///
    /// - Parameters:
    ///   - old: Original lines.
    ///   - new: New lines.
    ///   - contextLines: Number of context lines around changes.
    /// - Returns: Styled text representing the unified diff.
    public static func styled(
        _ old: [String],
        _ new: [String],
        contextLines: Cardinal = 3
    ) -> Test.Text {
        let changes = Sequence.Difference.diff(old, new)
        let (removed, inserted) = changes.counts()

        guard removed > .zero || inserted > .zero else {
            return Test.Text()
        }

        let diffHunks = changes.hunks(contextLines: contextLines)
        var segments: [Test.Text.Segment] = []

        for (hunkIndex, hunk) in diffHunks.enumerated() {
            if hunkIndex > 0 {
                segments.append(.init("\n", style: .plain))
            }

            segments.append(.init(hunk.header, style: .secondary))
            segments.append(.init("\n", style: .plain))

            for (lineIndex, line) in hunk.lines.enumerated() {
                let style: Test.Text.Segment.Style
                switch line {
                case .first: style = .diffRemoved
                case .second: style = .diffAdded
                case .both: style = .diffContext
                }

                segments.append(.init("\(line.marker)\(line.element)", style: style))

                // reason: Separator-not-last boundary on stdlib `[Hunk.Line]` iteration.
                // No typed Cardinal surface available at this site; the assertion
                // "lineIndex is not the last index" is naturally written as the
                // strict inequality against the last valid index (which is the
                // length-minus-one position). Algebraic-flip rephrase obscures
                // the math; restructuring via `enumerated() + offset > 0` inverts
                // the question (not-first vs not-last) which is a different intent.
                // swiftlint:disable:next cardinal_count_minus_one_anti_pattern
                if lineIndex < hunk.lines.count - 1 {
                    segments.append(.init("\n", style: .plain))
                }
            }
        }

        return Test.Text(segments)
    }
}
