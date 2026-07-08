import Foundation
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite
struct `Test.ID` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit

extension `Test.ID`.Unit {
    @Test
    func `init with suite stores all properties`() {
        let location = Source.Location.stub()
        let id = SUT.ID(
            module: "MyModule",
            suite: "MySuite",
            name: "testFoo",
            sourceLocation: location
        )
        #expect(id.module == "MyModule")
        #expect(id.suite == "MySuite")
        #expect(id.name == "testFoo")
        #expect(id.sourceLocation == location)
    }

    @Test
    func `init without suite defaults to nil`() {
        let id = SUT.ID.stub("testFoo")
        #expect(id.suite == nil)
    }

    @Test
    func `fullyQualifiedName includes module and name`() {
        let id = SUT.ID.stub("doSomething", module: "Mod")
        let fqn = id.fullyQualifiedName
        #expect(fqn.contains("Mod"))
        #expect(fqn.contains("doSomething"))
    }

    @Test
    func `fullyQualifiedName includes suite when present`() {
        let id = SUT.ID(
            module: "Mod",
            suite: "Suite",
            name: "test",
            sourceLocation: .stub()
        )
        #expect(id.fullyQualifiedName.contains("Suite"))
    }
}

// MARK: - EdgeCase

extension `Test.ID`.`Edge Case` {
    @Test
    func `codable round-trip`() throws {
        let original = SUT.ID(
            module: "M",
            suite: "S",
            name: "t",
            sourceLocation: .stub()
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SUT.ID.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `comparison is consistent`() {
        let a = SUT.ID(module: "A", name: "t", sourceLocation: .stub())
        let b = SUT.ID(module: "B", name: "t", sourceLocation: .stub())
        #expect(a < b)
        #expect(!(b < a))
    }
}
