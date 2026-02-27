import Testing
import Test_Primitives_Test_Support
import Foundation

private typealias SUT = Test_Primitives.Test

@Suite("Test.Snapshot.Recording")
struct TestSnapshotRecordingTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSnapshotRecordingTests.Unit {
    @Test
    func `allCases has four modes`() {
        #expect(SUT.Snapshot.Recording.allCases.count == 4)
    }

    @Test
    func `rawValues match expected strings`() {
        #expect(SUT.Snapshot.Recording.never.rawValue == "never")
        #expect(SUT.Snapshot.Recording.missing.rawValue == "missing")
        #expect(SUT.Snapshot.Recording.failed.rawValue == "failed")
        #expect(SUT.Snapshot.Recording.all.rawValue == "all")
    }

    @Test
    func `description is non-empty for all cases`() {
        for recording in SUT.Snapshot.Recording.allCases {
            #expect(!recording.description.isEmpty)
        }
    }
}

// MARK: - EdgeCase

extension TestSnapshotRecordingTests.EdgeCase {
    @Test
    func `codable round-trip for all cases`() throws {
        for original in SUT.Snapshot.Recording.allCases {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(SUT.Snapshot.Recording.self, from: data)
            #expect(decoded == original)
        }
    }

    @Test
    func `init from rawValue`() {
        #expect(SUT.Snapshot.Recording(rawValue: "never") == .never)
        #expect(SUT.Snapshot.Recording(rawValue: "missing") == .missing)
        #expect(SUT.Snapshot.Recording(rawValue: "invalid") == nil)
    }
}
