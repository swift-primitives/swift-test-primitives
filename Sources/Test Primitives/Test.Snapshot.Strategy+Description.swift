//
//  Test.Snapshot.Strategy+Description.swift
//  swift-test-primitives
//
//  Built-in description strategy for CustomStringConvertible types.
//

extension Test.Snapshot.Strategy where Format == String {
    /// Creates a strategy that uses `String(describing:)` for any value.
    ///
    /// Converts any value to its string description and uses line-by-line
    /// comparison. Useful for quick snapshots of types that have meaningful
    /// `description` implementations.
    ///
    /// File extension: `.txt`
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct User: CustomStringConvertible {
    ///     let name: String
    ///     let age: Int
    ///
    ///     var description: String {
    ///         "User(name: \(name), age: \(age))"
    ///     }
    /// }
    ///
    /// let user = User(name: "Alice", age: 30)
    /// try expectSnapshot(of: user, as: .description())
    /// ```
    ///
    /// - Returns: A strategy that snapshots any value via `String(describing:)`.
    public static func description<V>() -> Test.Snapshot.Strategy<V, String> {
        Test.Snapshot.Strategy<String, String>.lines.pullback { String(describing: $0) }
    }

    /// Creates a strategy using a value's `description` property.
    ///
    /// Similar to ``description()-6lnvq`` but specifically for types
    /// conforming to `CustomStringConvertible`.
    ///
    /// - Returns: A strategy that uses the value's `description` property.
    public static func customDescription<V: CustomStringConvertible>() -> Test.Snapshot.Strategy<V, String> {
        Test.Snapshot.Strategy<String, String>.lines.pullback { $0.description }
    }

    /// Creates a strategy using a value's `debugDescription` property.
    ///
    /// Uses `CustomDebugStringConvertible.debugDescription` which typically
    /// provides more detail than `description`.
    ///
    /// - Returns: A strategy that uses the value's `debugDescription` property.
    public static func debugDescription<V: CustomDebugStringConvertible>() -> Test.Snapshot.Strategy<V, String> {
        Test.Snapshot.Strategy<String, String>.lines.pullback { $0.debugDescription }
    }
}
