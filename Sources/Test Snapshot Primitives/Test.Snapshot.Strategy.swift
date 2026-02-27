//
//  Test.Snapshot.Strategy.swift
//  swift-test-primitives
//
//  Snapshot strategy type.
//

extension Test.Snapshot {
    /// A strategy for snapshotting values into a diffable format.
    ///
    /// `Strategy` encapsulates how to convert a value into a format
    /// that can be serialized, deserialized, and compared.
    ///
    /// ## Built-in Strategies
    ///
    /// - `Strategy<String, String>.lines` — Line-by-line text comparison
    /// - `Strategy<String, String>.text` — Full text comparison
    /// - `Strategy<[UInt8], [UInt8]>.data` — Binary comparison
    ///
    /// ## Custom Strategies
    ///
    /// Create custom strategies for your types using ``pullback(_:)``:
    ///
    /// ```swift
    /// extension Test.Snapshot.Strategy where Value == User, Format == String {
    ///     static var userDescription: Self {
    ///         Strategy<String, String>.lines.pullback { user in
    ///             """
    ///             User:
    ///               name: \(user.name)
    ///               age: \(user.age)
    ///             """
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Async Strategies
    ///
    /// For values requiring async capture (rendering, network, etc.):
    ///
    /// ```swift
    /// extension Test.Snapshot.Strategy where Value == WebView, Format == String {
    ///     static var html: Self {
    ///         Strategy(
    ///             pathExtension: "html",
    ///             diffing: .lines,
    ///             asyncSnapshot: { webView in
    ///                 Async.Callback {
    ///                     await withCheckedContinuation { continuation in
    ///                         webView.getHTML { html in
    ///                             continuation.resume(returning: html)
    ///                         }
    ///                     }
    ///                 }
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    public struct Strategy<Value, Format>: Sendable where Value: Sendable, Format: Sendable {
        /// File extension for snapshot files (e.g., "txt", "json", "png").
        ///
        /// Set to `nil` to use no extension.
        public var pathExtension: String?

        /// How to serialize, deserialize, and compare the format.
        public var diffing: Diffing<Format>

        /// The async snapshot capture function.
        ///
        /// Returns an `Async.Callback` that produces the format when called.
        /// This allows both synchronous and asynchronous capture.
        public var snapshot: @Sendable (Value) -> Async.Callback<Format>

        /// The sync snapshot capture function, if available.
        ///
        /// Non-nil when the strategy was created with a synchronous capture function.
        /// Used by sync `assertSnapshot` to avoid blocking.
        public var syncSnapshot: (@Sendable (Value) -> Format)?

        // MARK: - Initializers

        /// Creates a strategy with async capture.
        ///
        /// - Parameters:
        ///   - pathExtension: File extension for snapshot files.
        ///   - diffing: Serialization and comparison logic.
        ///   - asyncSnapshot: Function that returns an `Async.Callback` to capture the snapshot.
        public init(
            pathExtension: String?,
            diffing: Diffing<Format>,
            asyncSnapshot: @escaping @Sendable (_ value: Value) -> Async.Callback<Format>
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.snapshot = asyncSnapshot
            self.syncSnapshot = nil
        }

        /// Creates a strategy with synchronous capture.
        ///
        /// - Parameters:
        ///   - pathExtension: File extension for snapshot files.
        ///   - diffing: Serialization and comparison logic.
        ///   - snapshot: Synchronous function that captures the snapshot.
        public init(
            pathExtension: String?,
            diffing: Diffing<Format>,
            snapshot: @escaping @Sendable (_ value: Value) -> Format
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.syncSnapshot = snapshot
            self.snapshot = { value in Async.Callback(value: snapshot(value)) }
        }

        // MARK: - Internal Initializer

        /// Creates a strategy with both sync and async functions (internal use).
        init(
            pathExtension: String?,
            diffing: Diffing<Format>,
            syncSnapshot: (@Sendable (Value) -> Format)?,
            asyncSnapshot: @escaping @Sendable (Value) -> Async.Callback<Format>
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.syncSnapshot = syncSnapshot
            self.snapshot = asyncSnapshot
        }

        // MARK: - Composition

        /// Transforms this strategy to work with a different input type.
        ///
        /// "Pulls back" along a function `(NewValue) -> Value`, creating a strategy
        /// that can snapshot `NewValue` by first transforming to `Value`.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Strategy for User based on String.lines
        /// let userStrategy = Strategy<String, String>.lines.pullback { user in
        ///     "Name: \(user.name)\nAge: \(user.age)"
        /// }
        /// ```
        ///
        /// - Parameter transform: Function to transform new value to original value type.
        /// - Returns: A strategy for the new value type.
        public func pullback<NewValue: Sendable>(
            _ transform: @escaping @Sendable (_ otherValue: NewValue) -> Value
        ) -> Test.Snapshot.Strategy<NewValue, Format> {
            let capturedSnapshot = self.snapshot
            let capturedSyncSnapshot = self.syncSnapshot

            var newSyncSnapshot: (@Sendable (NewValue) -> Format)?
            if let sync = capturedSyncSnapshot {
                newSyncSnapshot = { newValue in sync(transform(newValue)) }
            }

            return Test.Snapshot.Strategy<NewValue, Format>(
                pathExtension: pathExtension,
                diffing: diffing,
                syncSnapshot: newSyncSnapshot,
                asyncSnapshot: { newValue in
                    capturedSnapshot(transform(newValue))
                }
            )
        }

        /// Transforms this strategy with an async transformation.
        ///
        /// Similar to the sync ``pullback(_:)`` but the transformation returns
        /// an `Async.Callback` that is awaited. The resulting strategy is always async-only.
        ///
        /// - Parameter transform: Function that returns an `Async.Callback` producing the original value type.
        /// - Returns: An async strategy for the new value type.
        public func asyncPullback<NewValue: Sendable>(
            _ transform: @escaping @Sendable (_ otherValue: NewValue) -> Async.Callback<Value>
        ) -> Test.Snapshot.Strategy<NewValue, Format> {
            let capturedSnapshot = self.snapshot
            return Test.Snapshot.Strategy<NewValue, Format>(
                pathExtension: pathExtension,
                diffing: diffing,
                asyncSnapshot: { newValue in
                    Async.Callback {
                        await capturedSnapshot(await transform(newValue)())()
                    }
                }
            )
        }

        // MARK: - Capture

        /// Captures a snapshot using Swift concurrency.
        ///
        /// Calls the `Async.Callback` and awaits the result.
        ///
        /// - Parameter value: The value to snapshot.
        /// - Returns: The captured format.
        public func capture(_ value: Value) async -> Format {
            await snapshot(value)()
        }

        /// Whether this strategy supports synchronous capture.
        public var isSynchronous: Bool {
            syncSnapshot != nil
        }
    }
}

// MARK: - SimplyStrategy (Value == Format)

extension Test.Snapshot {
    /// A strategy where `Value` and `Format` are the same type.
    ///
    /// This is convenient for types that are their own snapshot format,
    /// such as `String` or `[UInt8]`.
    public typealias SimplyStrategy<Format: Sendable> = Strategy<Format, Format>
}

extension Test.Snapshot.Strategy where Value == Format {
    /// Creates a strategy where the value type equals the format type.
    ///
    /// The snapshot function is identity—the value itself is the format.
    ///
    /// - Parameters:
    ///   - pathExtension: File extension for snapshot files.
    ///   - diffing: Serialization and comparison logic.
    public init(pathExtension: String?, diffing: Test.Snapshot.Diffing<Format>) {
        self.init(
            pathExtension: pathExtension,
            diffing: diffing,
            snapshot: { $0 }
        )
    }
}
