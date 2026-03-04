//
//  Test.Snapshot.Strategy+Redacting.swift
//  swift-test-primitives
//
//  Strategy composition with redactions.
//

extension Test.Snapshot.Strategy {
    /// Returns a new strategy that applies redactions after capture and before diffing.
    ///
    /// Redactions compose left-to-right: the first redaction's output feeds
    /// into the second, and so on.
    ///
    /// Both the synchronous and asynchronous capture paths are wrapped so that
    /// redactions apply regardless of which path the assertion function uses.
    ///
    /// - Parameter redactions: The redactions to apply in order.
    /// - Returns: A new strategy with redactions composed into its capture closures.
    public func redacting(
        _ redactions: [Test.Snapshot.Redaction<Format>]
    ) -> Self {
        guard !redactions.isEmpty else { return self }

        let redact: (Format) -> Format = { format in
            redactions.reduce(format) { result, redaction in
                redaction.apply(result)
            }
        }

        let capturedSnapshot = self.snapshot

        return Self(
            pathExtension: pathExtension,
            diffing: diffing,
            syncSnapshot: syncSnapshot.map { sync in
                { value in redact(sync(value)) }
            },
            asyncSnapshot: { value in
                Async.Callback {
                    redact(await capturedSnapshot(value)())
                }
            }
        )
    }

    /// Returns a new strategy that applies a single redaction after capture and before diffing.
    ///
    /// - Parameter redaction: The redaction to apply.
    /// - Returns: A new strategy with the redaction composed into its capture closures.
    public func redacting(
        _ redaction: Test.Snapshot.Redaction<Format>
    ) -> Self {
        redacting([redaction])
    }
}
