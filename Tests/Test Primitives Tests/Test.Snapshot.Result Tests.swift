import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite
struct `Test.Snapshot.Result` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Test.Snapshot.Result`.Unit {
    @Test
    func `matched is passing`() {
        let result = SUT.Snapshot.Result.matched
        #expect(result.isPassing)
        #expect(!result.isFailing)
    }

    @Test
    func `recorded is passing`() {
        let result = SUT.Snapshot.Result.recorded(path: "/snapshots/test.txt")
        #expect(result.isPassing)
        #expect(!result.isFailing)
    }

    @Test
    func `failed is failing`() {
        let diff = SUT.Snapshot.Diff.Result(summary: "1 line differs")
        let result = SUT.Snapshot.Result.failed(diff: diff, referencePath: "/ref.txt")
        #expect(result.isFailing)
        #expect(!result.isPassing)
    }

    @Test
    func `missingReference is failing`() {
        let result = SUT.Snapshot.Result.missingReference(path: "/ref.txt")
        #expect(result.isFailing)
        #expect(!result.isPassing)
    }

    @Test
    func `recordedInline is failing`() {
        let result = SUT.Snapshot.Result.recordedInline(sourceFile: "/Tests/MyTest.swift")
        #expect(result.isFailing)
        #expect(!result.isPassing)
    }
}

// MARK: - EdgeCase

extension `Test.Snapshot.Result`.`Edge Case` {
    @Test
    func `description is non-empty for all cases`() {
        let cases: [SUT.Snapshot.Result] = [
            .matched,
            .recorded(path: "/p"),
            .failed(diff: .init(summary: "diff"), referencePath: "/r"),
            .missingReference(path: "/m"),
            .recordedInline(sourceFile: "/t.swift"),
        ]
        for result in cases {
            #expect(!result.description.isEmpty)
        }
    }
}
