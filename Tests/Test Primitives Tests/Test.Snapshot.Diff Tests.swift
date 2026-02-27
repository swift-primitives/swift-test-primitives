import Testing
import Test_Primitives_Test_Support

private typealias SUT = Test_Primitives.Test

@Suite("Test.Snapshot.Diff")
struct TestSnapshotDiffTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSnapshotDiffTests.Unit {
    @Test
    func `diff identical sequences returns all both`() {
        let result = SUT.Snapshot.diff(["a", "b", "c"], ["a", "b", "c"])
        #expect(result.allSatisfy { difference in
            if case .both = difference { return true }
            return false
        })
    }

    @Test
    func `diff detects addition`() {
        let result = SUT.Snapshot.diff(["a", "c"], ["a", "b", "c"])
        let added = result.compactMap { difference -> String? in
            if case .second(let element) = difference { return element }
            return nil
        }
        #expect(added == ["b"])
    }

    @Test
    func `diff detects removal`() {
        let result = SUT.Snapshot.diff(["a", "b", "c"], ["a", "c"])
        let removed = result.compactMap { difference -> String? in
            if case .first(let element) = difference { return element }
            return nil
        }
        #expect(removed == ["b"])
    }

    @Test
    func `diff detects replacement`() {
        let result = SUT.Snapshot.diff(["a", "b"], ["a", "c"])
        let removed = result.compactMap { difference -> String? in
            if case .first(let e) = difference { return e }
            return nil
        }
        let added = result.compactMap { difference -> String? in
            if case .second(let e) = difference { return e }
            return nil
        }
        #expect(removed == ["b"])
        #expect(added == ["c"])
    }

    @Test
    func `changeCounts counts correctly`() {
        let differences = SUT.Snapshot.diff(["a", "b", "c"], ["a", "d"])
        let (removed, added) = SUT.Snapshot.changeCounts(differences)
        #expect(removed >= 1)
        #expect(added >= 1)
    }

    @Test
    func `hunks generates patch marks`() {
        let differences = SUT.Snapshot.diff(
            ["line1", "line2", "line3"],
            ["line1", "changed", "line3"]
        )
        let result = SUT.Snapshot.hunks(from: differences)
        #expect(!result.isEmpty)
        #expect(result[0].patchMark.hasPrefix("@@"))
    }

    @Test
    func `styledDiff produces styled text`() {
        let old = ["hello", "world"]
        let new = ["hello", "earth"]
        let text = SUT.Snapshot.styledDiff(old, new)
        #expect(!text.isEmpty)
        let styles = Set(text.segments.map(\.style))
        #expect(styles.contains(.diffRemoved) || styles.contains(.diffAdded))
    }
}

// MARK: - EdgeCase

extension TestSnapshotDiffTests.EdgeCase {
    @Test
    func `diff empty sequences`() {
        let result: [SUT.Snapshot.Difference<String>] = SUT.Snapshot.diff([], [])
        #expect(result.isEmpty)
    }

    @Test
    func `diff from empty to non-empty`() {
        let result = SUT.Snapshot.diff([], ["a", "b"])
        let added = result.compactMap { difference -> String? in
            if case .second(let e) = difference { return e }
            return nil
        }
        #expect(added == ["a", "b"])
    }

    @Test
    func `diff from non-empty to empty`() {
        let result = SUT.Snapshot.diff(["a", "b"], [])
        let removed = result.compactMap { difference -> String? in
            if case .first(let e) = difference { return e }
            return nil
        }
        #expect(removed == ["a", "b"])
    }

    @Test
    func `completely different sequences`() {
        let result = SUT.Snapshot.diff(["a", "b", "c"], ["x", "y", "z"])
        let (removed, added) = SUT.Snapshot.changeCounts(result)
        #expect(removed == 3)
        #expect(added == 3)
    }
}
