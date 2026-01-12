//
//  Test.Snapshot.Diff.swift
//  swift-test-primitives
//
//  Myers diff algorithm for line-based comparison.
//

extension Test.Snapshot {
    /// A difference in a sequence.
    public enum Difference<Element>: Sendable where Element: Sendable {
        /// Element exists only in the first sequence (removed).
        case first(Element)
        /// Element exists only in the second sequence (added).
        case second(Element)
        /// Element exists in both sequences (unchanged).
        case both(Element)
    }

    /// A hunk of differences for unified diff output.
    public struct Hunk: Sendable {
        /// Starting line in the original (1-indexed).
        public let oldStart: Int
        /// Number of lines from the original.
        public let oldCount: Int
        /// Starting line in the new (1-indexed).
        public let newStart: Int
        /// Number of lines in the new.
        public let newCount: Int
        /// The diff lines with their markers.
        public let lines: [(marker: Character, content: String)]

        /// Generates the patch mark line (e.g., "@@ -1,3 +1,4 @@").
        public var patchMark: String {
            "@@ -\(oldStart),\(oldCount) +\(newStart),\(newCount) @@"
        }
    }

    // MARK: - Myers Diff Algorithm

    /// Computes the differences between two sequences using Myers diff algorithm.
    ///
    /// This is an implementation of Eugene Myers' O(ND) difference algorithm
    /// that produces minimal edit scripts.
    ///
    /// - Parameters:
    ///   - old: The original sequence.
    ///   - new: The new sequence.
    /// - Returns: Array of differences.
    public static func diff<Element: Hashable & Sendable>(
        _ old: [Element],
        _ new: [Element]
    ) -> [Difference<Element>] {
        let n = old.count
        let m = new.count

        // Handle empty sequences
        if n == 0 {
            return new.map { .second($0) }
        }
        if m == 0 {
            return old.map { .first($0) }
        }

        // Build index map for old sequence
        var oldIndices: [Element: [Int]] = [:]
        for (index, element) in old.enumerated() {
            oldIndices[element, default: []].append(index)
        }

        // Find longest common subsequence using patience/LCS approach
        var lcs: [(oldIndex: Int, newIndex: Int)] = []
        var lastOldIndex = -1

        for (newIndex, element) in new.enumerated() {
            guard let indices = oldIndices[element] else { continue }
            // Find the smallest index in old that is greater than lastOldIndex
            for oldIndex in indices {
                if oldIndex > lastOldIndex {
                    lcs.append((oldIndex, newIndex))
                    lastOldIndex = oldIndex
                    break
                }
            }
        }

        // If LCS is empty, everything is different
        if lcs.isEmpty {
            var result: [Difference<Element>] = []
            result.reserveCapacity(n + m)
            for element in old {
                result.append(.first(element))
            }
            for element in new {
                result.append(.second(element))
            }
            return result
        }

        // Build result from LCS
        var result: [Difference<Element>] = []
        var oldPos = 0
        var newPos = 0

        for (oldIndex, newIndex) in lcs {
            // Add removed elements (in old but not matched)
            while oldPos < oldIndex {
                result.append(.first(old[oldPos]))
                oldPos += 1
            }
            // Add added elements (in new but not matched)
            while newPos < newIndex {
                result.append(.second(new[newPos]))
                newPos += 1
            }
            // Add matched element
            result.append(.both(old[oldIndex]))
            oldPos = oldIndex + 1
            newPos = newIndex + 1
        }

        // Add remaining elements
        while oldPos < n {
            result.append(.first(old[oldPos]))
            oldPos += 1
        }
        while newPos < m {
            result.append(.second(new[newPos]))
            newPos += 1
        }

        return result
    }

    // MARK: - Unified Diff

    /// Generates hunks from a diff for unified diff output.
    ///
    /// - Parameters:
    ///   - differences: The computed differences.
    ///   - contextLines: Number of context lines around changes (default: 3).
    /// - Returns: Array of hunks.
    public static func hunks<Element: Sendable>(
        from differences: [Difference<Element>],
        contextLines: Int = 3
    ) -> [Hunk] where Element: CustomStringConvertible {
        var hunks: [Hunk] = []
        var currentHunk: (
            oldStart: Int, oldCount: Int, newStart: Int, newCount: Int,
            lines: [(marker: Character, content: String)]
        )?

        var oldLine = 1
        var newLine = 1
        var contextBuffer: [(marker: Character, content: String, oldLine: Int, newLine: Int)] = []
        var lastChangeIndex = -1

        for (index, diff) in differences.enumerated() {
            let isChange: Bool
            let marker: Character
            let content: String

            switch diff {
            case .first(let element):
                isChange = true
                marker = "-"
                content = String(describing: element)
            case .second(let element):
                isChange = true
                marker = "+"
                content = String(describing: element)
            case .both(let element):
                isChange = false
                marker = " "
                content = String(describing: element)
            }

            if isChange {
                // Start new hunk if needed
                if currentHunk == nil {
                    // Include context from buffer
                    let contextStart = max(0, contextBuffer.count - contextLines)
                    let context = Array(contextBuffer[contextStart...])
                    let firstContext = context.first

                    currentHunk = (
                        oldStart: firstContext?.oldLine ?? oldLine,
                        oldCount: 0,
                        newStart: firstContext?.newLine ?? newLine,
                        newCount: 0,
                        lines: context.map { ($0.marker, $0.content) }
                    )

                    // Update counts for context
                    for c in context {
                        if c.marker == " " {
                            currentHunk?.oldCount += 1
                            currentHunk?.newCount += 1
                        }
                    }
                }

                // Add the change
                currentHunk?.lines.append((marker, content))
                if marker == "-" {
                    currentHunk?.oldCount += 1
                } else {
                    currentHunk?.newCount += 1
                }

                lastChangeIndex = index
                contextBuffer.removeAll()
            } else {
                // Context line
                if currentHunk != nil {
                    // Check if we should close the hunk
                    let distanceFromLastChange = index - lastChangeIndex
                    if distanceFromLastChange <= contextLines {
                        // Still within context range, add to current hunk
                        currentHunk?.lines.append((marker, content))
                        currentHunk?.oldCount += 1
                        currentHunk?.newCount += 1
                    } else if distanceFromLastChange == contextLines + 1 {
                        // Add final context and close hunk
                        currentHunk?.lines.append((marker, content))
                        currentHunk?.oldCount += 1
                        currentHunk?.newCount += 1
                    } else {
                        // Close current hunk
                        if let h = currentHunk {
                            hunks.append(Hunk(
                                oldStart: h.oldStart,
                                oldCount: h.oldCount,
                                newStart: h.newStart,
                                newCount: h.newCount,
                                lines: h.lines
                            ))
                        }
                        currentHunk = nil
                        contextBuffer.removeAll()
                    }
                }

                // Always buffer context for potential future hunks
                if currentHunk == nil {
                    contextBuffer.append((marker, content, oldLine, newLine))
                    if contextBuffer.count > contextLines {
                        contextBuffer.removeFirst()
                    }
                }
            }

            // Update line counters
            switch diff {
            case .first:
                oldLine += 1
            case .second:
                newLine += 1
            case .both:
                oldLine += 1
                newLine += 1
            }
        }

        // Close final hunk if open
        if let h = currentHunk {
            hunks.append(Hunk(
                oldStart: h.oldStart,
                oldCount: h.oldCount,
                newStart: h.newStart,
                newCount: h.newCount,
                lines: h.lines
            ))
        }

        return hunks
    }

    // MARK: - Styled Text Output

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
        let differences = diff(old, new)

        // If no differences, return empty
        let hasChanges = differences.contains { diff in
            switch diff {
            case .first, .second: return true
            case .both: return false
            }
        }

        guard hasChanges else {
            return Test.Text()
        }

        let diffHunks = hunks(from: differences, contextLines: contextLines)
        var segments: [Test.Text.Segment] = []

        for (hunkIndex, hunk) in diffHunks.enumerated() {
            if hunkIndex > 0 {
                segments.append(.init("\n", style: .plain))
            }

            // Add patch mark
            segments.append(.init(hunk.patchMark, style: .secondary))
            segments.append(.init("\n", style: .plain))

            // Add lines
            for (lineIndex, line) in hunk.lines.enumerated() {
                let style: Test.Text.Segment.Style
                switch line.marker {
                case "-":
                    style = .diffRemoved
                case "+":
                    style = .diffAdded
                default:
                    style = .diffContext
                }

                segments.append(.init("\(line.marker)\(line.content)", style: style))

                if lineIndex < hunk.lines.count - 1 {
                    segments.append(.init("\n", style: .plain))
                }
            }
        }

        return Test.Text(segments)
    }

    /// Counts the number of changed lines.
    ///
    /// - Parameter differences: The computed differences.
    /// - Returns: Tuple of (removed, added) line counts.
    public static func changeCounts<Element>(
        _ differences: [Difference<Element>]
    ) -> (removed: Int, added: Int) {
        var removed = 0
        var added = 0
        for diff in differences {
            switch diff {
            case .first: removed += 1
            case .second: added += 1
            case .both: break
            }
        }
        return (removed, added)
    }
}
