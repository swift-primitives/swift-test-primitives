import Byte_Primitives
import Test_Primitives_Test_Support
import Testing

private typealias SUT = Test_Primitives.Test

@Suite("Test.Attachment")
struct TestAttachmentTests {
    @Suite struct Unit {}
}

extension TestAttachmentTests.Unit {

    @Test func `init from bytes stores name and bytes`() {
        let attachment = SUT.Attachment(name: "diff.bin", bytes: [0x48, 0x49] as [Byte])
        #expect(attachment.name == "diff.bin")
        #expect(attachment.bytes == [0x48, 0x49])
    }

    @Test func `init from bytes stores content type`() {
        let attachment = SUT.Attachment(
            name: "img.png",
            bytes: [0x89, 0x50] as [Byte],
            contentType: "image/png"
        )
        #expect(attachment.contentType == "image/png")
    }

    @Test func `init from bytes defaults content type to nil`() {
        let attachment = SUT.Attachment(name: "data.bin", bytes: [] as [Byte])
        #expect(attachment.contentType == nil)
    }

    @Test func `init from string encodes as UTF-8`() {
        let attachment = SUT.Attachment(name: "msg.txt", string: "hello")
        #expect(attachment.bytes == "hello".utf8.map(Byte.init))
    }

    @Test func `init from string sets text content type`() {
        let attachment = SUT.Attachment(name: "msg.txt", string: "hello")
        #expect(attachment.contentType == "text/plain")
    }

    @Test func `collector starts empty`() {
        let collector = SUT.Attachment.Collector()
        #expect(collector.isEmpty)
        #expect(collector.drain().isEmpty)
    }

    @Test func `collector record and drain returns attachment`() {
        let collector = SUT.Attachment.Collector()
        collector.record(.init(name: "a.txt", string: "hello"))

        #expect(!collector.isEmpty)

        let drained = collector.drain()
        #expect(drained.count == 1)
        #expect(drained[0].name == "a.txt")
        #expect(collector.isEmpty)
    }

    @Test func `collector drain clears storage`() {
        let collector = SUT.Attachment.Collector()
        collector.record(.init(name: "a.txt", string: "data"))

        let first = collector.drain()
        #expect(first.count == 1)

        let second = collector.drain()
        #expect(second.isEmpty)
    }

    @Test func `collector accumulates multiple attachments in order`() {
        let collector = SUT.Attachment.Collector()
        collector.record(.init(name: "first.txt", string: "1"))
        collector.record(.init(name: "second.txt", string: "2"))
        collector.record(.init(name: "third.txt", string: "3"))

        let drained = collector.drain()
        #expect(drained.count == 3)
        #expect(drained[0].name == "first.txt")
        #expect(drained[1].name == "second.txt")
        #expect(drained[2].name == "third.txt")
    }
}
