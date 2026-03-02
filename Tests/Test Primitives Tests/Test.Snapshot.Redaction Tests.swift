import Testing
import Test_Primitives_Test_Support

private typealias SUT = Test_Primitives.Test

@Suite("Test.Snapshot.Redaction")
struct TestSnapshotRedactionTests {
    @Suite struct Unit {}
    @Suite struct Integration {}
}

extension TestSnapshotRedactionTests.Unit {

    @Test func `apply closure transforms format`() {
        let redaction = SUT.Snapshot.Redaction<String>(apply: { $0.uppercased() })
        #expect(redaction.apply("hello") == "HELLO")
    }

    @Test func `identity redaction returns format unchanged`() {
        let redaction = SUT.Snapshot.Redaction<String>(apply: { $0 })
        #expect(redaction.apply("unchanged") == "unchanged")
    }

    @Test func `redaction transforms non-string format`() {
        let redaction = SUT.Snapshot.Redaction<[UInt8]>(apply: { $0.map { $0 &+ 1 } })
        #expect(redaction.apply([0, 1, 2]) == [1, 2, 3])
    }

    @Test func `strategy redacting with empty list returns self`() {
        let base = SUT.Snapshot.Strategy<String, String>.lines
        let redacted = base.redacting([])
        #expect(redacted.pathExtension == base.pathExtension)
        #expect(redacted.syncSnapshot!("test") == base.syncSnapshot!("test"))
    }

    @Test func `strategy redacting wraps sync capture`() {
        let base = SUT.Snapshot.Strategy<Int, String>(
            pathExtension: "txt",
            diffing: .text,
            snapshot: { "\($0)" }
        )
        let redaction = SUT.Snapshot.Redaction<String>(apply: { "[\($0)]" })
        let redacted = base.redacting(redaction)

        #expect(redacted.isSynchronous)
        #expect(redacted.syncSnapshot!(42) == "[42]")
    }

    @Test func `strategy redacting wraps async capture`() async {
        let base = SUT.Snapshot.Strategy<Int, String>(
            pathExtension: "txt",
            diffing: .text,
            asyncSnapshot: { n in Async.Callback(value: "\(n)") }
        )
        let redaction = SUT.Snapshot.Redaction<String>(apply: { "[\($0)]" })
        let redacted = base.redacting(redaction)

        let result = await redacted.capture(42)
        #expect(result == "[42]")
    }

    @Test func `multiple redactions compose left to right`() {
        let r1 = SUT.Snapshot.Redaction<String>(apply: { $0.uppercased() })
        let r2 = SUT.Snapshot.Redaction<String>(apply: { $0 + "!" })
        let base = SUT.Snapshot.Strategy<String, String>.text
        let redacted = base.redacting([r1, r2])

        #expect(redacted.syncSnapshot!("hello") == "HELLO!")
    }

    @Test func `single redaction convenience delegates to array variant`() {
        let redaction = SUT.Snapshot.Redaction<String>(apply: { $0.uppercased() })
        let base = SUT.Snapshot.Strategy<String, String>.text
        let fromSingle = base.redacting(redaction)
        let fromArray = base.redacting([redaction])

        #expect(fromSingle.syncSnapshot!("abc") == fromArray.syncSnapshot!("abc"))
    }
}

extension TestSnapshotRedactionTests.Integration {

    @Test func `redacted strategy preserves path extension`() {
        let base = SUT.Snapshot.Strategy<String, String>(
            pathExtension: "json", diffing: .lines, snapshot: { $0 }
        )
        let redacted = base.redacting(SUT.Snapshot.Redaction<String>(apply: { $0 }))
        #expect(redacted.pathExtension == "json")
    }

    @Test func `redacted strategy preserves diffing`() {
        let base = SUT.Snapshot.Strategy<String, String>.lines
        let redacted = base.redacting(SUT.Snapshot.Redaction<String>(apply: { $0 }))
        #expect(redacted.diffing.diff("same", "same") == nil)
        #expect(redacted.diffing.diff("a", "b") != nil)
    }
}
