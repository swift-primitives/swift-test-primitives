import Byte_Primitives
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

// Strategy<Value, Format> is generic — use parallel namespace [TEST-004]

@Suite("Test.Snapshot.Strategy")
struct TestSnapshotStrategyTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestSnapshotStrategyTests.Unit {
    @Test
    func `sync strategy is synchronous`() {
        let strategy = SUT.Snapshot.Strategy<String, String>(
            pathExtension: "txt",
            diffing: .text
        )
        #expect(strategy.isSynchronous)
    }

    @Test
    func `sync strategy captures value`() {
        let strategy = SUT.Snapshot.Strategy<Int, String>(
            pathExtension: "txt",
            diffing: .text,
            snapshot: { "\($0)" }
        )
        #expect(strategy.syncSnapshot!(42) == "42")
    }

    @Test
    func `async strategy is not synchronous`() {
        let strategy = SUT.Snapshot.Strategy<String, String>(
            pathExtension: "txt",
            diffing: .text,
            asyncSnapshot: { value in Async.Callback(value: value) }
        )
        #expect(!strategy.isSynchronous)
    }

    @Test
    func `async capture produces format`() async {
        let strategy = SUT.Snapshot.Strategy<String, String>(
            pathExtension: "txt",
            diffing: .text
        )
        let result = await strategy.capture("hello")
        #expect(result == "hello")
    }

    @Test
    func `text strategy has txt extension`() {
        let strategy = SUT.Snapshot.Strategy<String, String>.text
        #expect(strategy.pathExtension == "txt")
        #expect(strategy.isSynchronous)
    }

    @Test
    func `lines strategy has txt extension`() {
        let strategy = SUT.Snapshot.Strategy<String, String>.lines
        #expect(strategy.pathExtension == "txt")
        #expect(strategy.isSynchronous)
    }

    @Test
    func `data strategy has bin extension`() {
        let strategy = SUT.Snapshot.Strategy<[Byte], [Byte]>.data
        #expect(strategy.pathExtension == "bin")
        #expect(strategy.isSynchronous)
    }

    @Test
    func `pullback transforms value`() {
        let intStrategy = SUT.Snapshot.Strategy<String, String>.text
            .pullback { (n: Int) in "\(n)" }
        #expect(intStrategy.syncSnapshot!(42) == "42")
        #expect(intStrategy.isSynchronous)
    }

    @Test
    func `pullback preserves path extension`() {
        let base = SUT.Snapshot.Strategy<String, String>.lines
        let pulled = base.pullback { (n: Int) in "\(n)" }
        #expect(pulled.pathExtension == base.pathExtension)
    }

    @Test
    func `description strategy uses String describing`() {
        let strategy: SUT.Snapshot.Strategy<Int, String> = .description()
        #expect(strategy.syncSnapshot!(42) == "42")
    }
}

// MARK: - EdgeCase

extension TestSnapshotStrategyTests.EdgeCase {
    @Test
    func `pullback chain composes`() {
        let strategy = SUT.Snapshot.Strategy<String, String>.text
            .pullback { (n: Int) in "\(n)" }
            .pullback { (arr: [Int]) in arr.first! }
        #expect(strategy.syncSnapshot!([99]) == "99")
    }

    @Test
    func `async pullback produces async-only strategy`() async {
        let strategy = SUT.Snapshot.Strategy<String, String>.text
            .asyncPullback { (n: Int) in Async.Callback(value: "\(n)") }
        #expect(!strategy.isSynchronous)
        let result = await strategy.capture(42)
        #expect(result == "42")
    }
}
