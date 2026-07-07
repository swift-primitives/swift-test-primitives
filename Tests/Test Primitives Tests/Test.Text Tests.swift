import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Text")
struct TestTextTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestTextTests.Unit {
    @Test
    func `init from string creates single plain segment`() {
        let text = SUT.Text("hello")
        #expect(text.segments.count == 1)
        #expect(text.segments[0].content == "hello")
        #expect(text.segments[0].style == .plain)
    }

    @Test
    func `string literal creates text`() {
        let text: SUT.Text = "hello"
        #expect(text.plainText == "hello")
    }

    @Test
    func `array literal creates text from segments`() {
        let text: SUT.Text = [
            SUT.Text.Segment("pass", style: .success),
            SUT.Text.Segment("fail", style: .failure),
        ]
        #expect(text.segments.count == 2)
    }

    @Test
    func `plainText concatenates all segment content`() {
        let text = SUT.Text([
            .init("hello ", style: .plain),
            .init("world", style: .emphasis),
        ])
        #expect(text.plainText == "hello world")
    }

    @Test
    func `isEmpty returns false for non-empty text`() {
        let text: SUT.Text = "hello"
        #expect(!text.isEmpty)
    }

    @Test
    func `concatenation combines segments`() {
        let a: SUT.Text = "hello "
        let b: SUT.Text = "world"
        let combined = a + b
        #expect(combined.plainText == "hello world")
        #expect(combined.segments.count == 2)
    }

    @Test
    func `segment string literal creates plain style`() {
        let segment: SUT.Text.Segment = "hello"
        #expect(segment.content == "hello")
        #expect(segment.style == .plain)
    }

    @Test
    func `segment styles count`() {
        #expect(SUT.Text.Segment.Style.allCases.count == 13)
    }
}

// MARK: - EdgeCase

extension TestTextTests.EdgeCase {
    @Test
    func `empty text is empty`() {
        let text = SUT.Text("")
        #expect(text.isEmpty)
    }

    @Test
    func `codable round-trip preserves styled segments`() throws {
        let text = SUT.Text([
            .init("pass", style: .success),
            .init(" — ", style: .plain),
            .init("test", style: .identifier),
        ])
        let data = try JSONEncoder().encode(text)
        let decoded = try JSONDecoder().decode(SUT.Text.self, from: data)
        #expect(decoded == text)
    }

    @Test
    func `plus-equals appends segments`() {
        var text: SUT.Text = "hello"
        text += " world"
        #expect(text.plainText == "hello world")
    }
}
