import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Expression")
struct TestExpressionTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension TestExpressionTests.Unit {
    @Test
    func `init stores all properties`() {
        let loc = Source.Location.stub()
        let expr = SUT.Expression(
            id: 1,
            sourceCode: "x == 42",
            sourceLocation: loc,
            values: []
        )
        #expect(expr.id == 1)
        #expect(expr.sourceCode == "x == 42")
        #expect(expr.sourceLocation == loc)
        #expect(expr.values.isEmpty)
    }

    @Test
    func `init with values`() {
        let value = SUT.Expression.Value(
            label: "lhs",
            stringValue: "42",
            typeDescription: "Int"
        )
        let expr = SUT.Expression(
            id: 2,
            sourceCode: "x == 42",
            sourceLocation: .stub(),
            values: [value]
        )
        #expect(expr.values.count == 1)
        #expect(expr.values[0].label == "lhs")
    }

    @Test
    func `Value init with label`() {
        let value = SUT.Expression.Value(
            label: "result",
            stringValue: "true",
            typeDescription: "Bool"
        )
        #expect(value.label == "result")
        #expect(value.stringValue == "true")
        #expect(value.typeDescription == "Bool")
        #expect(!value.isNil)
    }

    @Test
    func `Value init without label`() {
        let value = SUT.Expression.Value(
            stringValue: "hello",
            typeDescription: "String"
        )
        #expect(value.label == nil)
    }

    @Test
    func `Value capturing init captures description`() {
        let value = SUT.Expression.Value(capturing: 42, label: "x")
        #expect(value.stringValue == "42")
        #expect(value.label == "x")
        #expect(!value.isNil)
    }

    @Test
    func `Value capturing nil marks isNil`() {
        let opt: Int? = nil
        let value = SUT.Expression.Value(capturing: opt)
        #expect(value.isNil)
    }

    @Test
    func `Value capturing non-nil optional marks isNil false`() {
        let opt: Int? = 42
        let value = SUT.Expression.Value(capturing: opt)
        #expect(!value.isNil)
    }
}

// MARK: - EdgeCase

extension TestExpressionTests.EdgeCase {
    @Test
    func `codable round-trip`() throws {
        let original = SUT.Expression(
            id: 5,
            sourceCode: "a > b",
            sourceLocation: .stub(line: 10),
            values: [
                .init(label: "a", stringValue: "3", typeDescription: "Int"),
                .init(label: "b", stringValue: "1", typeDescription: "Int"),
            ]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.Expression.self, from: data)
        #expect(decoded == original)
    }
}
