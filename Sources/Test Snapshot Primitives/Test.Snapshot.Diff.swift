//
//  Test.Snapshot.Diff.swift
//  swift-test-primitives
//
//  Styled diff output bridge to Test.Text.
//

extension Test.Snapshot {
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
    public static func styledDiff(
        _ old: [String],
        _ new: [String],
        contextLines: Int = 3
    ) -> Test.Text {
        let changes = Sequence.Difference.diff(old, new)
        let (removed, inserted) = changes.counts()

        guard removed > .zero || inserted > .zero else {
            return Test.Text()
        }

        let diffHunks = changes.hunks(contextLines: try! Cardinal(contextLines))
        var segments: [Test.Text.Segment] = []

        for (hunkIndex, hunk) in diffHunks.enumerated() {
            if hunkIndex > 0 {
                segments.append(.init("\n", style: .plain))
            }

            segments.append(.init(hunk.patchMark, style: .secondary))
            segments.append(.init("\n", style: .plain))

            for (lineIndex, line) in hunk.lines.enumerated() {
                let style: Test.Text.Segment.Style
                switch line {
                case .first: style = .diffRemoved
                case .second: style = .diffAdded
                case .both: style = .diffContext
                }

                segments.append(.init("\(line.marker)\(line.element)", style: style))

                if lineIndex < hunk.lines.count - 1 {
                    segments.append(.init("\n", style: .plain))
                }
            }
        }

        return Test.Text(segments)
    }
}
