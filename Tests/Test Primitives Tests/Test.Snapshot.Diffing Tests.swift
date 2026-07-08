import Byte_Primitives
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite
struct `Test.Snapshot.Diffing` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Test.Snapshot.Diffing`.Unit {
    @Test
    func `text diffing round-trips through bytes`() {
        let diffing = SUT.Snapshot.Diffing<String>.text
        let original = "hello world"
        let bytes = diffing.toBytes(original)
        let restored = diffing.fromBytes(bytes)
        #expect(restored == original)
    }

    @Test
    func `text diffing detects identical strings as equal`() {
        let diffing = SUT.Snapshot.Diffing<String>.text
        let result = diffing.diff("hello", "hello")
        #expect(result == nil)
    }

    @Test
    func `text diffing detects different strings`() {
        let diffing = SUT.Snapshot.Diffing<String>.text
        let result = diffing.diff("hello", "world")
        #expect(result != nil)
    }

    @Test
    func `lines diffing round-trips through bytes`() {
        let diffing = SUT.Snapshot.Diffing<String>.lines
        let original = "line1\nline2\nline3"
        let bytes = diffing.toBytes(original)
        let restored = diffing.fromBytes(bytes)
        #expect(restored == original)
    }

    @Test
    func `lines diffing detects line changes`() {
        let diffing = SUT.Snapshot.Diffing<String>.lines
        let result = diffing.diff("line1\nline2", "line1\nchanged")
        #expect(result != nil)
        #expect(result?.summary.count ?? 0 > 0)
    }

    @Test
    func `lines diffing reports change counts in summary`() {
        let diffing = SUT.Snapshot.Diffing<String>.lines
        let result = diffing.diff("a\nb\nc", "a\nx\nc")
        #expect(result != nil)
        #expect(result?.unifiedDiff != nil)
    }

    @Test
    func `data diffing round-trips through bytes`() {
        let diffing = SUT.Snapshot.Diffing<[Byte]>.data
        let original: [Byte] = [0x01, 0x02, 0x03]
        let bytes = diffing.toBytes(original)
        let restored = diffing.fromBytes(bytes)
        #expect(restored == original)
    }

    @Test
    func `data diffing detects identical data as equal`() {
        let diffing = SUT.Snapshot.Diffing<[Byte]>.data
        let data: [Byte] = [1, 2, 3]
        let result = diffing.diff(data, data)
        #expect(result == nil)
    }

    @Test
    func `data diffing detects different data`() {
        let diffing = SUT.Snapshot.Diffing<[Byte]>.data
        let result = diffing.diff([1, 2, 3], [1, 4, 3])
        #expect(result != nil)
    }
}

// MARK: - EdgeCase

extension `Test.Snapshot.Diffing`.`Edge Case` {
    @Test
    func `lines diffing identical multiline strings are equal`() {
        let diffing = SUT.Snapshot.Diffing<String>.lines
        let text = "a\nb\nc\nd"
        let result = diffing.diff(text, text)
        #expect(result == nil)
    }

    @Test
    func `data diffing empty arrays are equal`() {
        let diffing = SUT.Snapshot.Diffing<[Byte]>.data
        let result = diffing.diff([], [])
        #expect(result == nil)
    }
}
