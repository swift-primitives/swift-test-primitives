import Test_Primitives_Test_Support
import Testing

@Suite
struct `CaseIterable Extensions` {
    @Suite struct Unit {}
}

// MARK: - Bool

extension `CaseIterable Extensions`.Unit {
    @Test
    func `Bool allCases has two elements`() {
        #expect(Bool.allCases.count == 2)
        #expect(Bool.allCases.contains(true))
        #expect(Bool.allCases.contains(false))
    }

    @Test
    func `Bool 2-tuple has 4 combinations`() {
        let cases = [(Bool, Bool)].allCases
        #expect(cases.count == 4)
    }

    @Test
    func `Bool 3-tuple has 8 combinations`() {
        let cases = [(Bool, Bool, Bool)].allCases
        #expect(cases.count == 8)
    }

    @Test
    func `Bool 4-tuple has 16 combinations`() {
        let cases = [(Bool, Bool, Bool, Bool)].allCases
        #expect(cases.count == 16)
    }

    @Test
    func `Bool 5-tuple has 32 combinations`() {
        let cases = [(Bool, Bool, Bool, Bool, Bool)].allCases
        #expect(cases.count == 32)
    }

    @Test
    func `Bool 6-tuple has 64 combinations`() {
        let cases = [(Bool, Bool, Bool, Bool, Bool, Bool)].allCases
        #expect(cases.count == 64)
    }
}

// MARK: - Bool?

extension `CaseIterable Extensions` {
    @Suite
    struct `Bool?` {
        @Suite struct Unit {}
    }
}

extension `CaseIterable Extensions`.`Bool?`.Unit {
    @Test
    func `Bool? allCases has three elements`() {
        let cases = Bool?.allCases
        #expect(cases.count == 3)
    }

    @Test
    func `Bool? allCases contains true false and nil`() {
        let cases = Bool?.allCases
        #expect(cases.contains(.some(true)))
        #expect(cases.contains(.some(false)))
        #expect(cases.contains(.none))
    }

    @Test
    func `Bool? 2-tuple has 9 combinations`() {
        let cases = [(Bool?, Bool?)].allCases
        #expect(cases.count == 9)
    }

    @Test
    func `Bool? 3-tuple has 27 combinations`() {
        let cases = [(Bool?, Bool?, Bool?)].allCases
        #expect(cases.count == 27)
    }

    @Test
    func `Bool? 4-tuple has 81 combinations`() {
        let cases = [(Bool?, Bool?, Bool?, Bool?)].allCases
        #expect(cases.count == 81)
    }

    @Test
    func `Bool? 5-tuple has 243 combinations`() {
        let cases = [(Bool?, Bool?, Bool?, Bool?, Bool?)].allCases
        #expect(cases.count == 243)
    }

    @Test
    func `Bool? 6-tuple has 729 combinations`() {
        let cases = [(Bool?, Bool?, Bool?, Bool?, Bool?, Bool?)].allCases
        #expect(cases.count == 729)
    }
}
