import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test
private typealias Diff = Sequence_Difference_Primitives.Sequence.Difference

@Suite("Test.Snapshot.Diff")
struct TestSnapshotDiffTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSnapshotDiffTests.Unit {
    @Test
    func `diff identical sequences returns all both`() {
        let result = Diff.diff(["a", "b", "c"], ["a", "b", "c"])
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            guard case .both = change else {
                Issue.record("Expected .both, got \(change)")
                return
            }
        }
    }

    @Test
    func `diff detects addition`() {
        let result = Diff.diff(["a", "c"], ["a", "b", "c"])
        var added: [String] = []
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            if case .second(let element) = change { added.append(element) }
        }
        #expect(added == ["b"])
    }

    @Test
    func `diff detects removal`() {
        let result = Diff.diff(["a", "b", "c"], ["a", "c"])
        var removed: [String] = []
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            if case .first(let element) = change { removed.append(element) }
        }
        #expect(removed == ["b"])
    }

    @Test
    func `diff detects replacement`() {
        let result = Diff.diff(["a", "b"], ["a", "c"])
        var removed: [String] = []
        var added: [String] = []
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            if case .first(let e) = change { removed.append(e) }
            if case .second(let e) = change { added.append(e) }
        }
        #expect(removed == ["b"])
        #expect(added == ["c"])
    }

    @Test
    func `counts counts correctly`() {
        let changes = Diff.diff(["a", "b", "c"], ["a", "d"])
        let (removed, added) = changes.counts()
        #expect(removed >= .one)
        #expect(added >= .one)
    }

    @Test
    func `hunks generates patch marks`() {
        let changes = Diff.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = changes.hunks()
        #expect(!result.isEmpty)
        #expect(result[0].patchMark.hasPrefix("@@"))
    }

    @Test
    func `Diff styled produces styled text`() {
        let old = ["hello", "world"]
        let new = ["hello", "earth"]
        let text = SUT.Snapshot.Diff.styled(old, new)
        #expect(!text.isEmpty)
        let styles = Set(text.segments.map(\.style))
        #expect(styles.contains(.diffRemoved) || styles.contains(.diffAdded))
    }
}

// MARK: - EdgeCase

extension TestSnapshotDiffTests.EdgeCase {
    @Test
    func `diff empty sequences`() {
        let empty: [String] = []
        let result = Diff.diff(empty, empty)
        let (removed, inserted) = result.counts()
        #expect(removed == .zero)
        #expect(inserted == .zero)
    }

    @Test
    func `diff from empty to non-empty`() {
        let result = Diff.diff([], ["a", "b"])
        var added: [String] = []
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            if case .second(let e) = change { added.append(e) }
        }
        #expect(added == ["a", "b"])
    }

    @Test
    func `diff from non-empty to empty`() {
        let result = Diff.diff(["a", "b"], [])
        var removed: [String] = []
        var iterator = result.makeIterator()
        while let change = iterator.next() {
            if case .first(let e) = change { removed.append(e) }
        }
        #expect(removed == ["a", "b"])
    }

    @Test
    func `completely different sequences`() {
        let result = Diff.diff(["a", "b", "c"], ["x", "y", "z"])
        let (removed, added) = result.counts()
        #expect(removed == 3)
        #expect(added == 3)
    }
}
