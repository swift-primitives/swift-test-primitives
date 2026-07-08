import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite
struct `Test.Snapshot.Diff.Result` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Test.Snapshot.Diff.Result`.Unit {
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
            summary: "1 line changed",
            unifiedDiff: diff
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

extension `Test.Snapshot.Diff.Result`.`Edge Case` {
    @Test
    func `codable round-trip`() throws {
        let diff: SUT.Text = [
            .init("-removed", style: .diffRemoved),
            .init("+added", style: .diffAdded),
        ]
        let original = SUT.Snapshot.Diff.Result(
            summary: "1 change",
            unifiedDiff: diff
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
