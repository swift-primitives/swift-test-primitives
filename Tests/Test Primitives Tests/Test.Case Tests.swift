// reason: Codable round-trip assertions below need JSONEncoder/JSONDecoder (test-only).
// swiftlint:disable:next no_foundation_import_warning
import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Case")
struct TestCaseTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestCaseTests.Unit {
    @Test
    func `init stores id and arguments`() {
        let testCase = SUT.Case(id: 42, arguments: "(x: 1, y: 2)")
        #expect(testCase.id == 42)
        #expect(testCase.arguments == "(x: 1, y: 2)")
    }

    @Test
    func `description includes arguments`() {
        let testCase = SUT.Case(id: 1, arguments: "(value: 42)")
        #expect(testCase.description.contains("42"))
    }
}

// MARK: - EdgeCase

extension TestCaseTests.EdgeCase {
    @Test
    func `codable round-trip`() throws {
        let original = SUT.Case(id: 99, arguments: "(a: true)")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Case.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `equal cases are equal`() {
        let a = SUT.Case(id: 1, arguments: "x")
        let b = SUT.Case(id: 1, arguments: "x")
        #expect(a == b)
    }

    @Test
    func `different ids make cases unequal`() {
        let a = SUT.Case(id: 1, arguments: "x")
        let b = SUT.Case(id: 2, arguments: "x")
        #expect(a != b)
    }
}
