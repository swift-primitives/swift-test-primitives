import Foundation
import Test_Primitives_Test_Support
import Testing

@Suite
struct `Source.Location` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Source.Location`.Unit {
    @Test
    func `init stores all properties`() {
        let location = Source.Location(
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
        let location = Source.Location(fileID: "M/F.swift", line: 1, column: 1)
        #expect(location.filePath == nil)
    }

    @Test
    func `description includes fileID and line`() {
        let location = Source.Location.stub(line: 42)
        let desc = location.description
        #expect(desc.contains("42"))
    }

    @Test
    func `equal locations are equal`() {
        let a = Source.Location.stub(line: 10)
        let b = Source.Location.stub(line: 10)
        #expect(a == b)
    }

    @Test
    func `different lines make locations unequal`() {
        let a = Source.Location.stub(line: 10)
        let b = Source.Location.stub(line: 20)
        #expect(a != b)
    }
}

// MARK: - EdgeCase

extension `Source.Location`.`Edge Case` {
    @Test
    func `comparison orders by fileID then line then column`() {
        let a = Source.Location(fileID: "A/F.swift", line: 1, column: 1)
        let b = Source.Location(fileID: "A/F.swift", line: 2, column: 1)
        let c = Source.Location(fileID: "B/F.swift", line: 1, column: 1)
        #expect(a < b)
        #expect(b < c)
    }

    @Test
    func `codable round-trip preserves all fields`() throws {
        let original = Source.Location(
            fileID: "M/F.swift",
            filePath: "/p",
            line: 42,
            column: 7
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Source.Location.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `equal values hash equally`() {
        let a = Source.Location.stub(line: 10)
        let b = Source.Location.stub(line: 10)
        #expect(a.hashValue == b.hashValue)
    }
}
