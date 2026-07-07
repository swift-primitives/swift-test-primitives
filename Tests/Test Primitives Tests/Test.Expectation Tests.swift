// reason: Codable round-trip assertions below need JSONEncoder/JSONDecoder (test-only).
// swiftlint:disable:next no_foundation_import_warning
import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Expectation")
struct TestExpectationTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestExpectationTests.Unit {
    @Test
    func `passing expectation`() {
        let expr = SUT.Expression(
            id: 1,
            sourceCode: "x == 42",
            sourceLocation: .stub()
        )
        let expectation = SUT.Expectation(
            id: 1,
            expression: expr,
            isPassing: true
        )
        #expect(expectation.isPassing)
        #expect(!expectation.isFailing)
        #expect(expectation.failure == nil)
    }

    @Test
    func `failing expectation with failure`() {
        let expr = SUT.Expression(
            id: 1,
            sourceCode: "x == 42",
            sourceLocation: .stub()
        )
        let failure = SUT.Expectation.Failure(
            message: "Expected 42, got 0"
        )
        let expectation = SUT.Expectation(
            id: 2,
            expression: expr,
            isPassing: false,
            failure: failure
        )
        #expect(!expectation.isPassing)
        #expect(expectation.isFailing)
        #expect(expectation.failure != nil)
    }

    @Test
    func `Failure stores all fields`() {
        let failure = SUT.Expectation.Failure(
            message: "mismatch",
            expected: .init(stringValue: "42", typeDescription: "Int"),
            actual: .init(stringValue: "0", typeDescription: "Int"),
            difference: "expected 42, got 0",
            comment: "check initial value"
        )
        #expect(failure.message.plainText == "mismatch")
        #expect(failure.expected?.stringValue == "42")
        #expect(failure.actual?.stringValue == "0")
        #expect(failure.difference != nil)
        #expect(failure.comment != nil)
    }

    @Test
    func `Failure defaults optionals to nil`() {
        let failure = SUT.Expectation.Failure(message: "failed")
        #expect(failure.expected == nil)
        #expect(failure.actual == nil)
        #expect(failure.difference == nil)
        #expect(failure.comment == nil)
    }
}

// MARK: - EdgeCase

extension TestExpectationTests.EdgeCase {
    @Test
    func `codable round-trip for passing`() throws {
        let original = SUT.Expectation(
            id: 1,
            expression: .init(id: 1, sourceCode: "true", sourceLocation: .stub()),
            isPassing: true
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Expectation.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `codable round-trip for failing with failure`() throws {
        let failure = SUT.Expectation.Failure(
            message: "mismatch",
            expected: .init(stringValue: "42", typeDescription: "Int")
        )
        let original = SUT.Expectation(
            id: 2,
            expression: .init(id: 1, sourceCode: "x == 42", sourceLocation: .stub()),
            isPassing: false,
            failure: failure
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Expectation.self, from: data)
        #expect(decoded == original)
    }
}
