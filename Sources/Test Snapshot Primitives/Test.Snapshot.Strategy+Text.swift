//
//  Test.Snapshot.Strategy+Text.swift
//  swift-test-primitives
//
//  Built-in text and lines strategies.
//

// MARK: - String Diffing

extension Test.Snapshot.Diffing where Format == String {
    /// Full text comparison diffing.
    ///
    /// Compares entire strings, reporting if they differ.
    public static var text: Self {
        Test.Snapshot.Diffing(
            toBytes: { Array($0.utf8) },
            fromBytes: { String(decoding: $0, as: UTF8.self) },
            diff: { old, new in
                guard old != new else { return nil }
                return Test.Snapshot.DiffResult(summary: "Text content differs")
            }
        )
    }

    /// Line-by-line comparison diffing with unified diff output.
    ///
    /// Splits strings by newlines and produces a unified diff showing
    /// exactly which lines were added, removed, or changed.
    public static var lines: Self {
        Test.Snapshot.Diffing(
            toBytes: { Array($0.utf8) },
            fromBytes: { String(decoding: $0, as: UTF8.self) },
            diff: { old, new in
                guard old != new else { return nil }

                let oldLines = old.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                let newLines = new.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

                let changes = Sequence.Difference.diff(oldLines, newLines)
                let (removed, added) = Sequence.Difference.counts(of: changes)

                let summary: String
                if removed == 0 {
                    summary = "\(added) line\(added == 1 ? "" : "s") added"
                } else if added == 0 {
                    summary = "\(removed) line\(removed == 1 ? "" : "s") removed"
                } else {
                    summary = "\(removed) line\(removed == 1 ? "" : "s") removed, \(added) line\(added == 1 ? "" : "s") added"
                }

                let styledDiff = Test.Snapshot.styledDiff(oldLines, newLines)

                return Test.Snapshot.DiffResult(
                    summary: summary,
                    unifiedDiff: styledDiff
                )
            }
        )
    }
}

// MARK: - String Strategies

extension Test.Snapshot.Strategy where Value == String, Format == String {
    /// Full text comparison strategy.
    ///
    /// Compares the entire string content. Best for short strings
    /// or when you want to compare without line-by-line analysis.
    ///
    /// File extension: `.txt`
    public static var text: Self {
        Test.Snapshot.Strategy(pathExtension: "txt", diffing: .text)
    }

    /// Line-by-line comparison strategy with unified diff output.
    ///
    /// Splits the string by newlines and produces a unified diff
    /// showing exactly which lines changed. Best for multi-line
    /// text, configuration files, or any structured text output.
    ///
    /// File extension: `.txt`
    ///
    /// ## Example Output
    ///
    /// ```diff
    /// @@ -1,3 +1,3 @@
    ///  Line 1
    /// -Line 2
    /// +Line 2 (modified)
    ///  Line 3
    /// ```
    public static var lines: Self {
        Test.Snapshot.Strategy(pathExtension: "txt", diffing: .lines)
    }
}
