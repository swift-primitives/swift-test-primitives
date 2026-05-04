import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Snapshot.Faceted")
struct TestSnapshotFacetedTests {
    @Suite struct Unit {}
}

extension TestSnapshotFacetedTests.Unit {

    @Test func `init stores primary and facets`() {
        let primary = SUT.Snapshot.Strategy<String, String>.lines
        let facets: [(name: String, strategy: SUT.Snapshot.Strategy<String, String>)] = [
            ("text", .text),
            ("lines", .lines),
        ]
        let faceted = SUT.Snapshot.Faceted<String>(primary: primary, facets: facets)

        #expect(faceted.primary.pathExtension == "txt")
        #expect(faceted.facets.count == 2)
        #expect(faceted.facets[0].name == "text")
        #expect(faceted.facets[1].name == "lines")
    }

    @Test func `facets are accessible by index`() {
        let faceted = SUT.Snapshot.Faceted<String>(
            primary: .lines,
            facets: [("alpha", .text), ("beta", .lines)]
        )
        #expect(faceted.facets[0].name == "alpha")
        #expect(faceted.facets[1].name == "beta")
        #expect(faceted.facets[0].strategy.isSynchronous)
        #expect(faceted.facets[1].strategy.isSynchronous)
    }

    @Test func `result all passing is passing`() {
        let result = SUT.Snapshot.Faceted<String>.Result(
            primary: .matched,
            facets: [
                (name: "text", result: .matched),
                (name: "lines", result: .recorded(path: "/tmp/x")),
            ]
        )
        #expect(result.isPassing)
        #expect(!result.isFailing)
    }

    @Test func `result primary failing is failing`() {
        let result = SUT.Snapshot.Faceted<String>.Result(
            primary: .missingReference(path: "/tmp/ref"),
            facets: [(name: "text", result: .matched)]
        )
        #expect(!result.isPassing)
        #expect(result.isFailing)
    }

    @Test func `result facet failing is failing`() {
        let result = SUT.Snapshot.Faceted<String>.Result(
            primary: .matched,
            facets: [
                (name: "ok", result: .matched),
                (
                    name: "bad",
                    result: .failed(
                        diff: .init(summary: "diff"),
                        referencePath: "/ref"
                    )
                ),
            ]
        )
        #expect(!result.isPassing)
        #expect(result.isFailing)
    }

    @Test func `result empty facets with passing primary is passing`() {
        let result = SUT.Snapshot.Faceted<String>.Result(
            primary: .matched,
            facets: []
        )
        #expect(result.isPassing)
        #expect(!result.isFailing)
    }
}
