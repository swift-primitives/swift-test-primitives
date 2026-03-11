import Testing
import Test_Primitives_Test_Support
import Foundation

private typealias SUT = Test_Primitives.Test

@Suite("Test.Trait")
struct TestTraitTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestTraitTests.Unit {
    @Test
    func `timeLimit factory`() {
        let trait = SUT.Trait.timeLimit(.seconds(30))
        #expect(trait.kind == .timeLimit(.seconds(30)))
    }

    @Test
    func `tag factory`() {
        let trait = SUT.Trait.tag("smoke")
        #expect(trait.kind == .tag("smoke"))
    }

    @Test
    func `enabled factory`() {
        let trait = SUT.Trait.enabled(if: true)
        #expect(trait.kind == .enabled(true, nil))
    }

    @Test
    func `enabled factory with comment`() {
        let trait = SUT.Trait.enabled(if: false, "not ready")
        #expect(trait.kind == .enabled(false, "not ready"))
    }

    @Test
    func `disabled factory creates enabled-false`() {
        let trait = SUT.Trait.disabled("reason")
        #expect(trait.kind == .enabled(false, "reason"))
    }

    @Test
    func `bug factory`() {
        let trait = SUT.Trait.bug("BUG-123", "crashes")
        #expect(trait.kind == .bug("BUG-123", "crashes"))
    }

    @Test
    func `serialized factory`() {
        let trait = SUT.Trait.serialized
        #expect(trait.kind == .serialized)
    }

    @Test
    func `exclusive factory`() {
        let trait = SUT.Trait.exclusive(group: "db")
        #expect(trait.kind == .exclusive("db"))
    }

    @Test
    func `exclusive factory defaults to global`() {
        let trait = SUT.Trait.exclusive
        #expect(trait.kind == .exclusive("__global__"))
    }

    @Test
    func `timed factory`() {
        let trait = SUT.Trait.timed(iterations: 20, warmup: 3)
        if case .timed(let config) = trait.kind {
            #expect(config.iteration.count == 20)
            #expect(config.iteration.warmup == 3)
        } else {
            Issue.record("Expected .timed kind")
        }
    }

    @Test
    func `sourceLocation defaults to nil`() {
        let trait = SUT.Trait.tag("x")
        #expect(trait.sourceLocation == nil)
    }

    @Test
    func `sourceLocation stores when provided`() {
        let loc = Source.Location.stub(line: 42)
        let trait = SUT.Trait(kind: .serialized, sourceLocation: loc)
        #expect(trait.sourceLocation == loc)
    }
}

// MARK: - EdgeCase

extension TestTraitTests.EdgeCase {
    @Test
    func `codable round-trip for tag`() throws {
        let original = SUT.Trait.tag("smoke")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Trait.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `codable round-trip for timeLimit`() throws {
        let original = SUT.Trait.timeLimit(.seconds(10))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Trait.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `codable round-trip for enabled with comment`() throws {
        let original = SUT.Trait.enabled(if: false, "reason")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Trait.self, from: data)
        #expect(decoded == original)
    }
}
