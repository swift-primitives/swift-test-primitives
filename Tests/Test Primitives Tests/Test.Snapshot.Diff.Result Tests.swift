import Testing
import Test_Primitives_Test_Support
import Foundation

private typealias SUT = Test_Primitives.Test

@Suite("Test.Snapshot.Diff.Result")
struct TestSnapshotDiffResultTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSnapshotDiffResultTests.Unit {
    @Test
    func `init with summary only`() {
        let result = SUT.Snapshot.Diff.Result(summary: "3 lines differ")
        #expect(result.summary == "3 lines differ")
        #expect(result.unifiedDiff == nil)
    }

    @Test
    func `init with summary and unifiedDiff`() {
        let diff: SUT.Text = [
            .init("-old", style: .diffRemoved),
            .init("+new", style: .diffAdded),
        ]
        let result = SUT.Snapshot.Diff.Result(
            summary: "1 line changed", unifiedDiff: diff
        )
        #expect(result.summary == "1 line changed")
        #expect(result.unifiedDiff != nil)
    }

    @Test
    func `description matches summary`() {
        let result = SUT.Snapshot.Diff.Result(summary: "test summary")
        #expect(result.description == "test summary")
    }
}

// MARK: - EdgeCase

extension TestSnapshotDiffResultTests.EdgeCase {
    @Test
    func `codable round-trip`() throws {
        let diff: SUT.Text = [
            .init("-removed", style: .diffRemoved),
            .init("+added", style: .diffAdded),
        ]
        let original = SUT.Snapshot.Diff.Result(
            summary: "1 change", unifiedDiff: diff
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Snapshot.Diff.Result.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `equal values are equal`() {
        let a = SUT.Snapshot.Diff.Result(summary: "same")
        let b = SUT.Snapshot.Diff.Result(summary: "same")
        #expect(a == b)
    }
}
