import Testing
import Test_Primitives_Test_Support
import Foundation

private typealias SUT = Test_Primitives.Test

@Suite("Test.Event")
struct TestEventTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestEventTests.Unit {
    @Test
    func `init with kind only`() {
        let event = SUT.Event(kind: .runStarted)
        #expect(event.id == nil)
        #expect(event.caseID == nil)
        #expect(event.elapsed == nil)
    }

    @Test
    func `init with all parameters`() {
        let testID = SUT.ID.stub("myTest")
        let event = SUT.Event(
            id: testID, caseID: 5,
            kind: .testStarted, elapsed: .seconds(1)
        )
        #expect(event.id == testID)
        #expect(event.caseID == 5)
        #expect(event.elapsed == .seconds(1))
    }

    @Test
    func `Result cases`() {
        #expect(SUT.Event.Result.passed != .failed)
        #expect(SUT.Event.Result.passed != .skipped)
        #expect(SUT.Event.Result.failed != .skipped)
    }

    @Test
    func `runStarted and runEnded kinds`() {
        let start = SUT.Event(kind: .runStarted)
        let end = SUT.Event(kind: .runEnded)
        #expect(start.description.contains("run"))
        #expect(end.description.contains("run"))
    }

    @Test
    func `testStarted and testEnded kinds`() {
        let id = SUT.ID.stub("test1")
        let start = SUT.Event(id: id, kind: .testStarted)
        let end = SUT.Event(id: id, kind: .testEnded(.passed))
        #expect(start.description.count > 0)
        #expect(end.description.count > 0)
    }

    @Test
    func `caseStarted and caseEnded kinds`() {
        let testCase = SUT.Case(id: 1, arguments: "(x: 1)")
        let start = SUT.Event(kind: .caseStarted(testCase))
        let end = SUT.Event(kind: .caseEnded(testCase))
        #expect(start.description.count > 0)
        #expect(end.description.count > 0)
    }

    @Test
    func `expectationChecked kind`() {
        let expectation = SUT.Expectation(
            id: 1,
            expression: .init(id: 1, sourceCode: "true", sourceLocation: .stub()),
            isPassing: true
        )
        let event = SUT.Event(kind: .expectationChecked(expectation))
        #expect(event.description.count > 0)
    }

    @Test
    func `issueRecorded kind`() {
        let issue = SUT.Issue(kind: .unconditional("fail"))
        let event = SUT.Event(kind: .issueRecorded(issue))
        #expect(event.description.count > 0)
    }

    @Test
    func `custom kind`() {
        let event = SUT.Event(kind: .custom(name: "metric", payload: "42"))
        #expect(event.description.count > 0)
    }
}

// MARK: - EdgeCase

extension TestEventTests.EdgeCase {
    @Test
    func `codable round-trip for simple kind`() throws {
        let original = SUT.Event(kind: .runStarted)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        // Event is not Equatable — compare properties
        #expect(decoded.id == original.id)
        #expect(decoded.caseID == original.caseID)
        #expect(decoded.elapsed == original.elapsed)
    }

    @Test
    func `codable round-trip for event with test ID`() throws {
        let original = SUT.Event(
            id: .stub("t"), caseID: 3,
            kind: .testEnded(.failed), elapsed: .milliseconds(500)
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.caseID == original.caseID)
        #expect(decoded.elapsed == original.elapsed)
    }

    @Test
    func `Result codable round-trip`() throws {
        for result in [SUT.Event.Result.passed, .failed, .skipped] {
            let data = try JSONEncoder().encode(result)
            let decoded = try JSONDecoder().decode(SUT.Event.Result.self, from: data)
            #expect(decoded == result)
        }
    }

    @Test
    func `codable round-trip for caseStarted kind`() throws {
        let testCase = SUT.Case(id: 1, arguments: "(x: 1)")
        let original = SUT.Event(kind: .caseStarted(testCase))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.caseID == original.caseID)
    }

    @Test
    func `codable round-trip for expectationChecked kind`() throws {
        let expectation = SUT.Expectation(
            id: 1,
            expression: .init(id: 1, sourceCode: "x == 42", sourceLocation: .stub()),
            isPassing: true
        )
        let original = SUT.Event(kind: .expectationChecked(expectation))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
    }

    @Test
    func `codable round-trip for issueRecorded kind`() throws {
        let issue = SUT.Issue(
            kind: .errorCaught(type: "IOError", description: "file not found"),
            sourceLocation: .stub(line: 42),
            isKnown: true
        )
        let original = SUT.Event(kind: .issueRecorded(issue))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
    }

    @Test
    func `codable round-trip for custom kind`() throws {
        let original = SUT.Event(kind: .custom(name: "metric", payload: "42"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
    }

    @Test
    func `codable round-trip for testSkipped kind`() throws {
        let original = SUT.Event(kind: .testSkipped("not ready"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
    }
}
