//
//  Test.Snapshot.Strategy+Data.swift
//  swift-test-primitives
//
//  Built-in binary data strategy.
//

public import Byte_Primitives

// MARK: - Data Diffing

extension Test.Snapshot.Diffing where Format == [Byte] {
    /// Binary data comparison diffing.
    ///
    /// Compares byte arrays, reporting size differences and the
    /// offset of the first differing byte.
    public static var data: Self {
        Test.Snapshot.Diffing(
            toBytes: { $0 },
            fromBytes: { $0 },
            diff: { old, new in
                guard old != new else { return nil }

                // Find first difference
                var firstDiffOffset: Int?
                let minLength = min(old.count, new.count)

                for i in 0..<minLength {
                    if old[i] != new[i] {
                        firstDiffOffset = i
                        break
                    }
                }

                // If no diff found in common prefix, diff is at the end
                if firstDiffOffset == nil && old.count != new.count {
                    firstDiffOffset = minLength
                }

                let summary: String
                if old.count != new.count {
                    if let offset = firstDiffOffset {
                        summary = "Binary data differs: expected \(old.count) bytes, got \(new.count) bytes (first difference at offset \(offset))"
                    } else {
                        summary = "Binary data differs: expected \(old.count) bytes, got \(new.count) bytes"
                    }
                } else if let offset = firstDiffOffset {
                    summary = "Binary data differs at offset \(offset) (both \(old.count) bytes)"
                } else {
                    summary = "Binary data differs"
                }

                return Test.Snapshot.Diff.Result(summary: summary)
            }
        )
    }
}

// MARK: - Data Strategy

extension Test.Snapshot.Strategy where Value == [Byte], Format == [Byte] {
    /// Binary data comparison strategy.
    ///
    /// Compares raw byte arrays. Best for binary files, images,
    /// or any non-text data.
    ///
    /// File extension: `.bin`
    ///
    /// ## Diff Output
    ///
    /// Reports:
    /// - Size differences (expected vs actual byte count)
    /// - Offset of first differing byte
    ///
    /// Note: Does not produce a visual diff since binary data
    /// is not human-readable.
    public static var data: Self {
        Test.Snapshot.Strategy(pathExtension: "bin", diffing: .data)
    }
}
