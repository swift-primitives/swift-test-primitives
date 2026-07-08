import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite
struct `Test.Issue` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Test.Issue`.Unit {
    @Test
    func `init with kind only`() {
        let issue = SUT.Issue(kind: .unconditional("something wrong"))
        #expect(issue.sourceLocation == nil)
        #expect(!issue.isKnown)
        #expect(issue.context == nil)
    }

    @Test
    func `init with all parameters`() {
        let loc = Source.Location.stub(line: 42)
        let issue = SUT.Issue(
            kind: .unconditional("msg"),
            sourceLocation: loc,
            isKnown: true,
            context: "during setup"
        )
        #expect(issue.sourceLocation == loc)
        #expect(issue.isKnown)
        #expect(issue.context?.plainText == "during setup")
    }

    @Test
    func `unconditional kind`() {
        let issue = SUT.Issue(kind: .unconditional("forced fail"))
        #expect(issue.kind == .unconditional("forced fail"))
    }

    @Test
    func `expectationFailed kind`() {
        let issue = SUT.Issue(kind: .expectationFailed(7))
        #expect(issue.kind == .expectationFailed(7))
    }

    @Test
    func `confirmationMiscounted kind`() {
        let issue = SUT.Issue(kind: .confirmationMiscounted(actual: 3, expected: 1))
        #expect(issue.kind == .confirmationMiscounted(actual: 3, expected: 1))
    }

    @Test
    func `errorCaught kind`() {
        let issue = SUT.Issue(kind: .errorCaught(type: "IOError", description: "file not found"))
        #expect(issue.kind == .errorCaught(type: "IOError", description: "file not found"))
    }

    @Test
    func `timeLimitExceeded kind`() {
        let issue = SUT.Issue(kind: .timeLimitExceeded(limit: .seconds(30)))
        #expect(issue.kind == .timeLimitExceeded(limit: .seconds(30)))
    }

    @Test
    func `knownIssueNotRecorded kind`() {
        let issue = SUT.Issue(kind: .knownIssueNotRecorded)
        #expect(issue.kind == .knownIssueNotRecorded)
    }

    @Test
    func `apiMisused kind`() {
        let issue = SUT.Issue(kind: .apiMisused("wrong usage"))
        #expect(issue.kind == .apiMisused("wrong usage"))
    }

    @Test
    func `system kind`() {
        let issue = SUT.Issue(kind: .system("internal error"))
        #expect(issue.kind == .system("internal error"))
    }
}

// MARK: - EdgeCase

extension `Test.Issue`.`Edge Case` {
    @Test
    func `codable round-trip`() throws {
        let original = SUT.Issue(
            kind: .errorCaught(type: "E", description: "msg"),
            sourceLocation: .stub(line: 10),
            isKnown: true,
            context: "ctx"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Issue.self, from: data)
        #expect(decoded == original)
    }
}
