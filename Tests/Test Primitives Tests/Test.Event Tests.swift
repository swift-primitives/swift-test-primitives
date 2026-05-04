import Foundation
import Test_Primitives_Test_Support
import Testing

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
        #expect(event.result == nil)
        #expect(event.testCase == nil)
        #expect(event.reason == nil)
        #expect(event.expectation == nil)
        #expect(event.issue == nil)
    }

    @Test
    func `init with all parameters`() {
        let testID = SUT.ID.stub("myTest")
        let event = SUT.Event(
            id: testID,
            caseID: 5,
            kind: .testStarted,
            elapsed: .seconds(1)
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
        let end = SUT.Event(id: id, kind: .testEnded, result: .passed)
        #expect(start.description.count > 0)
        #expect(end.description.count > 0)
        #expect(end.result == .passed)
    }

    @Test
    func `caseStarted and caseEnded kinds`() {
        let testCase = SUT.Case(id: 1, arguments: "(x: 1)")
        let start = SUT.Event(kind: .caseStarted, testCase: testCase)
        let end = SUT.Event(kind: .caseEnded, testCase: testCase)
        #expect(start.testCase?.arguments == "(x: 1)")
        #expect(end.testCase?.arguments == "(x: 1)")
    }

    @Test
    func `expectationChecked kind`() {
        let expectation = SUT.Expectation(
            id: 1,
            expression: .init(id: 1, sourceCode: "true", sourceLocation: .stub()),
            isPassing: true
        )
        let event = SUT.Event(kind: .expectationChecked, expectation: expectation)
        #expect(event.expectation?.isPassing == true)
    }

    @Test
    func `issueRecorded kind`() {
        let issue = SUT.Issue(kind: .unconditional("fail"))
        let event = SUT.Event(kind: .issueRecorded, issue: issue)
        #expect(event.issue != nil)
    }

    @Test
    func `payload round-trip`() {
        let event = SUT.Event(
            kind: .init(_unchecked: "performanceDiagnostic"),
            payload: "{\"metric\":\"median\"}"
        )
        #expect(event.payload == "{\"metric\":\"median\"}")
        #expect(event.description.contains("payload:"))
    }

    @Test
    func `payload defaults to nil`() {
        let event = SUT.Event(kind: .runStarted)
        #expect(event.payload == nil)
    }

    @Test
    func `extensible kind via rawValue`() {
        let custom = SUT.Event.Kind(_unchecked: "metric")
        let event = SUT.Event(kind: custom)
        #expect(event.kind.underlying == "metric")
        #expect(event.kind == custom)
    }

    @Test
    func `Kind equality`() {
        #expect(SUT.Event.Kind.runStarted == .runStarted)
        #expect(SUT.Event.Kind.runStarted != .runEnded)
        #expect(SUT.Event.Kind.testEnded != .testStarted)
    }
}

// MARK: - EdgeCase

extension TestEventTests.EdgeCase {
    @Test
    func `codable round-trip for simple kind`() throws {
        let original = SUT.Event(kind: .runStarted)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.caseID == original.caseID)
        #expect(decoded.elapsed == original.elapsed)
        #expect(decoded.kind == original.kind)
    }

    @Test
    func `codable round-trip for event with test ID`() throws {
        let original = SUT.Event(
            id: .stub("t"),
            caseID: 3,
            kind: .testEnded,
            elapsed: .milliseconds(500),
            result: .failed
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.caseID == original.caseID)
        #expect(decoded.elapsed == original.elapsed)
        #expect(decoded.kind == .testEnded)
        #expect(decoded.result == SUT.Event.Result.failed)
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
        let original = SUT.Event(kind: .caseStarted, testCase: testCase)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind == .caseStarted)
        #expect(decoded.testCase?.arguments == "(x: 1)")
    }

    @Test
    func `codable round-trip for expectationChecked kind`() throws {
        let expectation = SUT.Expectation(
            id: 1,
            expression: .init(id: 1, sourceCode: "x == 42", sourceLocation: .stub()),
            isPassing: true
        )
        let original = SUT.Event(kind: .expectationChecked, expectation: expectation)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind == .expectationChecked)
        #expect(decoded.expectation?.isPassing == true)
    }

    @Test
    func `codable round-trip for issueRecorded kind`() throws {
        let issue = SUT.Issue(
            kind: .errorCaught(type: "IOError", description: "file not found"),
            sourceLocation: .stub(line: 42),
            isKnown: true
        )
        let original = SUT.Event(kind: .issueRecorded, issue: issue)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind == .issueRecorded)
        #expect(decoded.issue?.isKnown == true)
    }

    @Test
    func `codable round-trip for event with payload`() throws {
        let original = SUT.Event(
            kind: .init(_unchecked: "performanceDiagnostic"),
            payload: "{\"test\":\"data\"}"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind.underlying == "performanceDiagnostic")
        #expect(decoded.payload == "{\"test\":\"data\"}")
    }

    @Test
    func `codable round-trip for extensible kind`() throws {
        let original = SUT.Event(kind: .init(_unchecked: "metric"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind.underlying == "metric")
    }

    @Test
    func `codable round-trip for testSkipped kind`() throws {
        let original = SUT.Event(kind: .testSkipped, reason: "not ready")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Event.self, from: data)
        #expect(decoded.kind == .testSkipped)
        #expect(decoded.reason?.plainText == "not ready")
    }

    @Test
    func `Kind codable round-trip`() throws {
        let kinds: [SUT.Event.Kind] = [
            .runStarted, .planCreated, .runEnded,
            .testStarted, .testEnded, .testSkipped,
            .caseStarted, .caseEnded,
            .expectationChecked, .issueRecorded,
            .init(_unchecked: "custom"),
        ]
        for kind in kinds {
            let data = try JSONEncoder().encode(kind)
            let decoded = try JSONDecoder().decode(SUT.Event.Kind.self, from: data)
            #expect(decoded == kind)
        }
    }
}
