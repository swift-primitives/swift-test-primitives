import Testing
import Test_Primitives_Test_Support
import Foundation

private typealias SUT = Test_Primitives.Test

@Suite("Test.Source.Location")
struct TestSourceLocationTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSourceLocationTests.Unit {
    @Test
    func `init stores all properties`() {
        let location = SUT.Source.Location(
            fileID: "Module/File.swift",
            filePath: "/path/File.swift",
            line: 42,
            column: 7
        )
        #expect(location.fileID == "Module/File.swift")
        #expect(location.filePath == "/path/File.swift")
        #expect(location.line == 42)
        #expect(location.column == 7)
    }

    @Test
    func `filePath defaults to nil`() {
        let location = SUT.Source.Location(fileID: "M/F.swift", line: 1, column: 1)
        #expect(location.filePath == nil)
    }

    @Test
    func `description includes fileID and line`() {
        let location = SUT.Source.Location.stub(line: 42)
        let desc = location.description
        #expect(desc.contains("42"))
    }

    @Test
    func `equal locations are equal`() {
        let a = SUT.Source.Location.stub(line: 10)
        let b = SUT.Source.Location.stub(line: 10)
        #expect(a == b)
    }

    @Test
    func `different lines make locations unequal`() {
        let a = SUT.Source.Location.stub(line: 10)
        let b = SUT.Source.Location.stub(line: 20)
        #expect(a != b)
    }
}

// MARK: - EdgeCase

extension TestSourceLocationTests.EdgeCase {
    @Test
    func `comparison orders by fileID then line then column`() {
        let a = SUT.Source.Location(fileID: "A/F.swift", line: 1, column: 1)
        let b = SUT.Source.Location(fileID: "A/F.swift", line: 2, column: 1)
        let c = SUT.Source.Location(fileID: "B/F.swift", line: 1, column: 1)
        #expect(a < b)
        #expect(b < c)
    }

    @Test
    func `codable round-trip preserves all fields`() throws {
        let original = SUT.Source.Location(
            fileID: "M/F.swift", filePath: "/p", line: 42, column: 7
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Source.Location.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `equal values hash equally`() {
        let a = SUT.Source.Location.stub(line: 10)
        let b = SUT.Source.Location.stub(line: 10)
        #expect(a.hashValue == b.hashValue)
    }
}
