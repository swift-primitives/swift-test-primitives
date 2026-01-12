//
//  Test.Snapshot.Strategy.swift
//  swift-test-primitives
//
//  Snapshotting strategy type.
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
    ///                 await webView.getHTML()
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    public struct Strategy<Value, Format>: Sendable {
        /// File extension for snapshot files (e.g., "txt", "json", "png").
        public let pathExtension: String

        /// How to serialize, deserialize, and compare the format.
        public let diffing: Diffing<Format>

        /// Synchronous snapshot capture function.
        ///
        /// Either this or ``asyncSnapshot`` must be non-nil.
        public let snapshot: (@Sendable (Value) -> Format)?

        /// Asynchronous snapshot capture function.
        ///
        /// Used for values requiring async capture (rendering, network, etc.).
        /// Either this or ``snapshot`` must be non-nil.
        public let asyncSnapshot: (@Sendable (Value) async -> Format)?

        // MARK: - Initializers

        /// Creates a synchronous strategy.
        ///
        /// - Parameters:
        ///   - pathExtension: File extension for snapshot files.
        ///   - diffing: Serialization and comparison logic.
        ///   - snapshot: Converts value to format synchronously.
        public init(
            pathExtension: String,
            diffing: Diffing<Format>,
            snapshot: @escaping @Sendable (Value) -> Format
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.snapshot = snapshot
            self.asyncSnapshot = nil
        }

        /// Creates an asynchronous strategy.
        ///
        /// - Parameters:
        ///   - pathExtension: File extension for snapshot files.
        ///   - diffing: Serialization and comparison logic.
        ///   - asyncSnapshot: Converts value to format asynchronously.
        public init(
            pathExtension: String,
            diffing: Diffing<Format>,
            asyncSnapshot: @escaping @Sendable (Value) async -> Format
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.snapshot = nil
            self.asyncSnapshot = asyncSnapshot
        }

        // MARK: - Internal Initializer

        /// Creates a strategy with both sync and async functions (internal use).
        init(
            pathExtension: String,
            diffing: Diffing<Format>,
            snapshot: (@Sendable (Value) -> Format)?,
            asyncSnapshot: (@Sendable (Value) async -> Format)?
        ) {
            self.pathExtension = pathExtension
            self.diffing = diffing
            self.snapshot = snapshot
            self.asyncSnapshot = asyncSnapshot
        }

        // MARK: - Composition

        /// Transforms this strategy to work with a different input type.
        ///
        /// "Pulls back" along a function `(NewValue) -> Value`, creating a strategy
        /// that can snapshot `NewValue` by first transforming to `Value`.
        ///
        /// There's also an async overload for async transformations.
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
        public func pullback<NewValue>(
            _ transform: @escaping @Sendable (NewValue) -> Value
        ) -> Test.Snapshot.Strategy<NewValue, Format> {
            var newSnapshot: (@Sendable (NewValue) -> Format)?
            var newAsyncSnapshot: (@Sendable (NewValue) async -> Format)?

            if let snap = snapshot {
                newSnapshot = { newValue in snap(transform(newValue)) }
            }
            if let asyncSnap = asyncSnapshot {
                newAsyncSnapshot = { newValue in await asyncSnap(transform(newValue)) }
            }

            return Test.Snapshot.Strategy<NewValue, Format>(
                pathExtension: pathExtension,
                diffing: diffing,
                snapshot: newSnapshot,
                asyncSnapshot: newAsyncSnapshot
            )
        }

        /// Transforms this strategy with an async transformation.
        ///
        /// Similar to the sync ``pullback(_:)`` but the transformation is async.
        /// The resulting strategy will always be async.
        ///
        /// - Parameter transform: Async function to transform new value to original value type.
        /// - Returns: An async strategy for the new value type.
        public func pullback<NewValue>(
            _ transform: @escaping @Sendable (NewValue) async -> Value
        ) -> Test.Snapshot.Strategy<NewValue, Format> {
            let capturedSnapshot = self.snapshot
            let capturedAsyncSnapshot = self.asyncSnapshot
            let newAsyncSnapshot: @Sendable (NewValue) async -> Format = { newValue in
                let value = await transform(newValue)
                if let snap = capturedSnapshot {
                    return snap(value)
                } else if let asyncSnap = capturedAsyncSnapshot {
                    return await asyncSnap(value)
                } else {
                    fatalError("Strategy has neither sync nor async snapshot function")
                }
            }
            return Test.Snapshot.Strategy<NewValue, Format>(
                pathExtension: pathExtension,
                diffing: diffing,
                snapshot: nil,
                asyncSnapshot: newAsyncSnapshot
            )
        }

        // MARK: - Capture

        /// Captures a snapshot of the value.
        ///
        /// Uses the sync function if available, otherwise awaits the async function.
        ///
        /// - Parameter value: The value to snapshot.
        /// - Returns: The snapshotted format.
        public func capture(_ value: Value) async -> Format {
            if let snap = snapshot {
                return snap(value)
            } else if let asyncSnap = asyncSnapshot {
                return await asyncSnap(value)
            } else {
                fatalError("Strategy has neither sync nor async snapshot function")
            }
        }

        /// Captures a snapshot synchronously.
        ///
        /// - Precondition: The strategy must have a sync snapshot function.
        /// - Parameter value: The value to snapshot.
        /// - Returns: The snapshotted format.
        public func captureSync(_ value: Value) -> Format {
            guard let snap = snapshot else {
                fatalError("Strategy does not have a sync snapshot function. Use capture(_:) async instead.")
            }
            return snap(value)
        }

        /// Whether this strategy supports synchronous capture.
        public var isSynchronous: Bool {
            snapshot != nil
        }
    }
}

// MARK: - SimplySnapshotting (Value == Format)

extension Test.Snapshot.Strategy where Value == Format {
    /// Creates a strategy where the value type equals the format type.
    ///
    /// The snapshot function is identity—the value itself is the format.
    ///
    /// - Parameters:
    ///   - pathExtension: File extension for snapshot files.
    ///   - diffing: Serialization and comparison logic.
    public init(pathExtension: String, diffing: Test.Snapshot.Diffing<Format>) {
        self.init(
            pathExtension: pathExtension,
            diffing: diffing,
            snapshot: { $0 }
        )
    }
}
